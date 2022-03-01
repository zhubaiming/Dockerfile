#################### 自定义函数 ####################

# 根据正则替换内容
function trim(str)
{
    # sub(r,s,t) 在整个t中用s替换r（r可以是正则表达式）

    # 替换开头的空格
    sub(/^[[:space:]]+/, "", str)
    # 替换结尾的空格
    sub(/[[:space:]]+$/, "", str)

    return str
}

# 查询给定文本中指定内容的个数
function num(str, needle)
{
    ret = 0
    while (i = index(str, needle)) {
        ret++
        str = substr(str, i + length(needle))
    }
    return ret
}

# 将需要直接输出的内容变成字符串
function jq_escape(str)
{
    # 从命令中读取输出：把命令放入引号中，然后利用管道将命令输出传入 getline
    # "command" | getline output;

    prog = "jq --raw-input --slurp ."
    printf "%s", str |& prog
    close(prog, "to")
    prog |& getline out
    e = close(prog)
    if (e != 0) {
        exit(e)
    }
    return out
}

# 拼接当前内容
function append_string(str)
{
	if (!str) return

	# append_string 的内容都是非逻辑部分，均使用 jq 输出成带有 "" 包裹的内容
	str = jq_escape(str)

	append(out)
}

# 处理非直接输出内容的格式
function append_jq(expr)
{
    expr = trim(expr)    # 处理传入内容的两侧空格
    if (!expr) return

    if (expr ~ /^#/) return

    # expr 可能的内容：

    # env.from

    #  echo "我是单行命令，单行闭合" end

    # .url => (.url)

    # if xxx then (     => (if xxx then (
    # ) else (          => ) else (
    # ) end             => ) end)

    # 将以上内容变形为："FROM demo\n\n\nENV PHP_URL="+(.url)+(if 1 == 1 then ("aa") else ("bb") end)

    if (expr !~ /^\)/) expr = "(" expr

    if (expr !~ /\($/) expr = expr ")"

    append(expr)
}

# 拼接全文内容
function append(str) {
	if (jq_expr && jq_expr !~ /\($/ && str !~ /^\)/) {
		jq_expr = jq_expr "\n+ "
	} else if (jq_expr) {
		jq_expr = jq_expr "\n"
	}

	jq_expr = jq_expr str
}

# 运行前
BEGIN {
    printf "#\n# NOTE: 当前文件由 \"apply_templates.sh\" 生成\n#\n# 请勿直接修改\n#\n\n"

    OPEN = "{{"
    CLOSE = "}}"
    CLOSE_EAT_EOL = "-" CLOSE ORS

    agg_text = ""
    agg_jq = ""
    # 用于保存拼接后的全文内容
    jq_expr = ""

}

# 运行中
{
    line = $0 ORS

    i = 0
    if (agg_jq || (i = index(line, OPEN))) {
        if (i) {
            agg_text = agg_text substr(line, 1, i - 1)
            line = substr(line, i)
        }

        append_string(agg_text)
        agg_text = ""

        agg_jq = agg_jq line
        line = ""

        if (num(agg_jq, OPEN) > num(agg_jq, CLOSE)) {
            next
        }

        while (i = index(agg_jq, OPEN)) {
            line = substr(agg_jq, 1, i - 1)
            agg_jq = substr(agg_jq, i + length(OPEN))
            if (match(agg_jq, CLOSE_EAT_EOL)) {
                i = RSTART
                CL = RLENGTH - 1
            } else {
                i = index(agg_jq, CLOSE)
                CL = length(CLOSE)
            }
            expr = substr(agg_jq, 1, i - 1)
            agg_jq = substr(agg_jq, i + CL)

            append_string(line)
            append_jq(expr)
        }

        line = agg_jq
        agg_jq = ""
    }

    if (line) {
        agg_text = agg_text line
    }
}

# 运行后
END {
    # 将最后一次出现执行符 OPEN 后的内容全部添加到全局内容之中
    append_string(agg_text)

    jq_expr = ".[env.version] | (\n" jq_expr "\n)"

    prog = "jq --join-output --from-file /dev/stdin php_versions.json"
    printf "%s", jq_expr | prog
    e = close(prog)
    if (e != 0) {
        exit(e)
    }

    printf "\n\n# 本文件由作者：baiming.zhu 编写并维护，版权所有"
}