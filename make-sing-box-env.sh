#!/bin/bash
IFS_BAK=$IFS
IFS=$'\n'
set -e

echo "检查操作系统..."

if [[ "$(uname)" != "Linux" ]]; then
  echo "本脚本仅支持 Linux。"
  exit 1
fi

echo "操作系统是 Linux"

# 检查 brew 是否已安装
if ! command -v apt >/dev/null 2>&1; then
  echo "未检测到 apt..."
  exit 2
else
  echo "已安装 apt"
fi

# 更新 apt 软件包信息
echo "正在更新 apt..."
sudo apt update

# 安装 unzip（解压 .zip）
echo "安装/升级 uuid..."
sudo apt -y install unzip || sudo apt -y upgrade unzip

# 安装 uuid（生成时间戳）
echo "安装/升级 uuid..."
sudo apt -y install uuid || sudo apt -y upgrade uuid

# 安装 unar（解压 .rar/.zip）
echo "安装/升级 unar..."
sudo apt -y install unar || sudo apt -y upgrade unar

echo "所有工具安装完成"

USER_HOME="$HOME"
SING_BOX_DIR_PATH="${USER_HOME}/Desktop/sing-boxs"
if [[ ! -d ${SING_BOX_DIR_PATH} && ! -f ${SING_BOX_DIR_PATH} ]]; then
  SING_BOX_DIR=${SING_BOX_DIR_PATH}'/sing-box_config'
else
  SING_BOX_DIR_PATH=${SING_BOX_DIR_PATH}-$(uuid)
  SING_BOX_DIR=${SING_BOX_DIR_PATH}'/sing-box_config'
fi

# 订阅链接
echo "请输入你的订阅链接SUBS，不输入直接回车则使用默认但不保证节点有效:"
echo "默认 'https://panlongid.com/wp-content/uploads/nodelist/202508/20250901-base64-dmN9su.txt' "
read -r -s SUBS
SUBS=${SUBS:-'https://panlongid.com/wp-content/uploads/nodelist/202508/20250901-base64-dmN9su.txt'}
urlencode() {
  local LANG=C
  local length="${#1}"
  for (( i = 0; i < length; i++ )); do
    local c="${1:i:1}"
    case $c in
      [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
      *) printf '%%%02X' "'$c" ;;
    esac
  done
}
SUBS=$(urlencode ${SUBS})
# 规则策略模版
#echo "请输入你的规则策略模版链接RULES，不输入直接回车则使用默认但不保证模版有效:"
#echo "默认 'https://github.com/juewuy/ShellCrash/raw/master/rules/ShellClash_Full_Block.ini' "
#read -r RULES
#RULES=${RULES:-'https://github.com/juewuy/ShellCrash/raw/master/rules/ShellClash_Full_Block.ini'}
# 在线订阅转换API接口
echo "请输入你的在线订阅转换API链接SUBS_API，不输入直接回车则使用默认但不保证转换有效:"
echo "默认 'https://sub.d1.mk/sub' "
read -r SUBS_API
SUBS_API=${SUBS_API:-'https://sub.d1.mk/sub'}
#SUB_URL=${SUBS_API}'?target=singbox&insert=true&new_name=true&scv=true&udp=true&exclude=&include=&url='${SUBS}'&config='${RULES}
SUB_URL=${SUBS_API}'?target=singbox&insert=true&new_name=true&scv=true&udp=true&exclude=&include=&url='${SUBS}
SING_BOX_PATH='/SagerNet/sing-box/releases/download/v1.13.0-beta.7'
VERSION=sing-box-$(basename ${SING_BOX_PATH} | tr 'A-Z' 'a-z' | sed 's;v;;g')-linux-arm64.tar.gz
echo "https://github.com${SING_BOX_PATH}/${VERSION}"
SING_BOX_BIN_FILE_URL="https://github.com${SING_BOX_PATH}/${VERSION}"
SING_BOX_BIN_FILE_GZ="${SING_BOX_DIR_PATH}/${VERSION}"
SING_BOX_BIN_FILE="$(echo ${SING_BOX_BIN_FILE_GZ} | sed 's;.tar.gz;;g')"
SING_BOX_BIN_FILE_RENAME="${SING_BOX_DIR_PATH}/sing-box"
UI_PATH=$(curl -SL --connect-timeout 30 -m 60 --speed-time 30 --speed-limit 1 --retry 2 -H "Connection: keep-alive" -k 'https://github.com/Zephyruso/zashboard/releases' | sed 's;";\n;g;s;tag;download;g' | grep '/download/' | head -n 1)
UI_URL="https://github.com${UI_PATH}/dist.zip"
UI_FILE=${SING_BOX_DIR}'/ui.zip'
SING_BOX_CONFIG_TEMPLATES_URL="https://github.com/469138946ba5fa/make-sing-box-envs-nanopir3s-armbian/raw/refs/heads/master/1.13.0-beta.7.json"
SING_BOX_CONFIG_TEMPLATES_FILE=${SING_BOX_DIR_PATH}'/1.13.0-beta.7.json'
TMP_FILE=${SING_BOX_DIR_PATH}'/temp_config.json'
OUT_FILE=${SING_BOX_DIR_PATH}'/out_config.json'
BASE_FILE=${SING_BOX_DIR_PATH}'/base_config.json'
SING_BOX_FILE=${SING_BOX_DIR_PATH}'/config.json'
NODES=${SING_BOX_DIR_PATH}'/filtered_nodes.json'
NODES_CONFIG=${SING_BOX_DIR_PATH}'/config_with_nodes.json'
# other
#游戏_469138946ba5fa|游戏|Game|加速|Steam|Origin|🎮
#流媒体_469138946ba5fa|Netflix|奈飞|Media|NF|Disney|YouTube|流媒体|🎥
#省流_469138946ba5fa|省流|低倍率|大流量|0.1x|0.2x|📺
#高级_469138946ba5fa|专线|高级|IEPL|IPLC|AIA|CTM|CC|Premium|👍
GROUPS_PATTERNS=$(cat <<'469138946ba5fa'
日本_469138946ba5fa|日本|JP|Tokyo|东京|大阪|🇯🇵
美国_469138946ba5fa|美|US|United States|洛杉矶|芝加哥|硅谷|圣何塞|🇺🇲
新加坡_469138946ba5fa|坡|SG|Singapore|狮城|🇸🇬
香港_469138946ba5fa|港|HK|Hong Kong|🇭🇰
台湾_469138946ba5fa|台|TW|Taiwan|彰化|新北|🇨🇳
韩国_469138946ba5fa|韩|KR|Korea|首尔|🇰🇷
智能_469138946ba5fa|disney|openai|gemini|🤖
469138946ba5fa
)
BASE_SING_BOX_CONFIG_FIXSCRIPT=$(cat <<'469138946ba5fa'
# 需要用 Python 或 JSON 专用工具转换
#command -v python
import json
import sys

def ensure_tls_insecure(node):
    """
    为支持 TLS 的 outbound 节点插入 tls.insecure = true
    """
    if not isinstance(node, dict):
        return node

    tls_supported = {"http", "vmess", "trojan", "hysteria", "vless", "shadowtls", "tuic", "hysteria2", "anytls", "reality"}

    if node.get("type") in tls_supported:
        tls = node.get("tls")
        if isinstance(tls, dict):
            if "insecure" not in tls:
                tls["insecure"] = True
        else:
            node["tls"] = {"enabled": True, "insecure": True}

    return node

input_path = sys.argv[1]
output_path = sys.argv[2]

with open(input_path, "r", encoding="utf-8") as f:
    data = json.load(f)

if isinstance(data, dict) and isinstance(data.get("outbounds"), list):
    data["outbounds"] = [ensure_tls_insecure(node) for node in data["outbounds"]]

with open(output_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"修复完成，所有 outbounds 节点已确保包含 tls.insecure: true → {output_path}")
469138946ba5fa
)
GROUPS_FILE=${SING_BOX_DIR_PATH}'/group_patterns.txt'
BASE_CONFIG_FIXSCRIPT_FILE=${SING_BOX_DIR_PATH}'/subs-fix.py'
SING_BOX_START=${SING_BOX_DIR_PATH}'/sing-box-start.sh'

mkdir -pv ${SING_BOX_DIR}

curl -L -C - --retry 3 --retry-delay 5 --progress-bar -o ${SING_BOX_BIN_FILE_GZ} ${SING_BOX_BIN_FILE_URL}
[ ! -f "$SING_BOX_BIN_FILE_GZ" ] && echo "sing-box压缩文件不存在：$SING_BOX_BIN_FILE_GZ" && exit 1
curl -L -C - --retry 3 --retry-delay 5 --progress-bar -o ${UI_FILE} ${UI_URL}
[ ! -f "$UI_FILE" ] && echo "UI压缩文件不存在：$UI_FILE" && exit 1
curl -L -C - --retry 3 --retry-delay 5 --progress-bar -o ${SING_BOX_CONFIG_TEMPLATES_FILE} ${SING_BOX_CONFIG_TEMPLATES_URL}
[ ! -f "$SING_BOX_CONFIG_TEMPLATES_FILE" ] && echo "模板配置文件不存在：$SING_BOX_CONFIG_TEMPLATES_FILE" && exit 1

unar -f ${SING_BOX_BIN_FILE_GZ} -o ${SING_BOX_DIR_PATH}
mv -fv ${SING_BOX_BIN_FILE}/sing-box ${SING_BOX_BIN_FILE_RENAME}
rm -frv ${SING_BOX_BIN_FILE}
chmod -v a+x ${SING_BOX_BIN_FILE_RENAME}
if [[ -d ${SING_BOX_DIR}/ui ]]; then
  rm -frv ${SING_BOX_DIR}/ui
fi
unzip -o ${SING_BOX_DIR}'/ui.zip' -d ${SING_BOX_DIR}
mv -fv ${SING_BOX_DIR}/dist ${SING_BOX_DIR}/ui

# 合并自定义头部 + 提取部分
echo "${GROUPS_PATTERNS}" > "${GROUPS_FILE}"
[ ! -f "$GROUPS_FILE" ] && echo "分组定义文件不存在：$GROUPS_FILE" && exit 1
echo "${BASE_SING_BOX_CONFIG_FIXSCRIPT}" > "${BASE_CONFIG_FIXSCRIPT_FILE}"
[ ! -f "$BASE_CONFIG_FIXSCRIPT_FILE" ] && echo "修复脚本文件不存在：$BASE_CONFIG_FIXSCRIPT_FILE" && exit 1

chmod -Rv a+x ${SING_BOX_DIR_PATH}
chown -Rv $USER ${SING_BOX_DIR_PATH}

cat << 469138946ba5fa | tee ${SING_BOX_START}
#!/bin/bash
IFS_BAK=\$IFS
IFS=\$'\n'
set -e

echo "start sing-box..."
if [ -f '${TMP_FILE}' ]; then
  rm -fv '${TMP_FILE}'
fi

# -L --retry 3 --retry-delay 5 --progress-bar 
if curl -k -L --retry 3 --retry-delay 5 --progress-bar -o '${TMP_FILE}' '${SUB_URL}'; then
    # curl 成功，继续检查文件内容
    if [ ! -s '${TMP_FILE}' ]; then # -s 检查文件是否存在且大小不为0
        echo "Error: ${TMP_FILE} is empty or not created after curl. Exiting."
        exit 1
    fi
    echo "Temporary config downloaded to ${TMP_FILE}"
else
    # curl 失败
    echo "Error: curl download failed. Exiting."
    exit 2
fi

[ ! -f '${TMP_FILE}' ] && echo "原始节点文件不存在：${TMP_FILE}" && exit 1

# 从订阅中提取节点
jq '[.outbounds[] | select(.server != null and .server != "")]' '$TMP_FILE' > '$NODES'
[ ! -f "$NODES" ] && echo "全节点文件不存在：$NODES" && exit 1

# 将节点全部插入到 `.outbounds`
jq --slurpfile new_nodes '$NODES' '
  .outbounds += \$new_nodes[0]
' '$SING_BOX_CONFIG_TEMPLATES_FILE' > config_tmp.json && mv -fv config_tmp.json '$NODES_CONFIG'
[ ! -f "$NODES_CONFIG" ] && echo "节点配置文件不存在：$NODES_CONFIG" && exit 1

# 将节点名全部插入到 自动_469138946ba5fa
jq --slurpfile new_nodes '$NODES' '
  .outbounds |= map(
    if .tag == "自动_469138946ba5fa" and .type == "urltest" then
      .outbounds = (\$new_nodes[0] | map(.tag))
    else
      .
    end
  )
' '$NODES_CONFIG' > config_tmp.json && mv -fv config_tmp.json '$NODES_CONFIG'

# 将节点名全部插入到 手动_469138946ba5fa
jq --slurpfile new_nodes '$NODES' '
  .outbounds |= map(
    if .tag == "手动_469138946ba5fa" and .type == "selector" then
      .outbounds = (\$new_nodes[0] | map(.tag))
    else
      .
    end
  )
' '$NODES_CONFIG' > config_tmp.json && mv -fv config_tmp.json '$NODES_CONFIG'

# 遍历分组定义文件，每行格式：tag|pattern
while IFS='|' read -r tag pattern; do
  echo "处理分组：\$tag"

  # 获取匹配到的节点 tag 列表
  matched=\$(jq --arg pattern "\$pattern" '
    [.[] | select(.tag | test(\$pattern; "i")) | .tag]
  ' '$NODES')

  # 如果没有匹配结果，跳过
  if [ "\$(echo "\$matched" | jq 'length')" -eq 0 ]; then
    echo "  ➤ 无匹配节点，跳过"
    continue
  fi

  # 判断分组是否存在
  exists=\$(jq --arg tag "\$tag" '.outbounds[] | select(.tag == \$tag)' '$NODES_CONFIG')

  if [ -z "\$exists" ]; then
    echo "  ➤ 分组不存在，创建新 selector"
    jq --arg tag "\$tag" --argjson outbounds "\$matched" '
      .outbounds += [{
        type: "selector",
        tag: \$tag,
        outbounds: \$outbounds
      }]
    ' '$NODES_CONFIG' > config_tmp.json && mv -fv config_tmp.json '$NODES_CONFIG'
  else
    echo "  ➤ 分组已存在，更新节点列表"
    jq --arg tag "\$tag" --argjson outbounds "\$matched" '
      .outbounds |= map(
        if .tag == \$tag and (.type == "selector" or .type == "urltest") then
          . + {outbounds: \$outbounds}
        else
          .
        end
      )
    ' '$NODES_CONFIG' > config_tmp.json && mv -fv config_tmp.json '$NODES_CONFIG'
  fi
done < '$GROUPS_FILE'

cp -fv '${NODES_CONFIG}' '${SING_BOX_FILE}'
[ ! -f "$SING_BOX_FILE" ] && echo "新节点配置文件不存在：$SING_BOX_FILE" && exit 1

# 修复 sing-box config.json 中自动选择策略的 url-test 设置
if [ -f '${SING_BOX_FILE}' ]; then
    echo "正在增强自动选择策略组配置..."

    # 替换测试 URL 为更稳定的 Cloudflare
    # 修复 sing-box config.json 中自动选择策略的 url-test 设置
    jq '
      # 1. 修改 mixed 的 listen_port
      .inbounds |= map(
        if .type == "mixed" then
          .listen_port = 7890
        else
          .
        end
      )
      # 2. 修改 urltest 对象
      | (.outbounds[] | select(.type=="urltest")) |=
          (.url = "http://cp.cloudflare.com/generate_204"
           | .interval = "3m0s"
           | .tolerance = 30)
      # 3. 修改 experimental.clash_api 的 external_controller / external_ui（如果存在）
      | if .experimental? and .experimental.clash_api? then
          .experimental.clash_api.external_controller = ":9999"
          | .experimental.clash_api.external_ui = "ui"
        else
          .
        end
      ## 4. 插入或修改 DNS UDP 53 inbound
      #| if any(.inbounds[]; .type=="direct" and .network=="udp") then
      #    .inbounds |= map(
      #      if .type=="direct" and .network=="udp" then
      #        .listen_port = 53
      #      else
      #        .
      #      end
      #    )
      #  else
      #    .inbounds += [{
      #      "type": "direct",
      #      "tag": "DNS入站_469138946ba5fa",
      #      "listen": "0.0.0.0",
      #      "listen_port": 53,
      #      "sniff_override_destination": true,
      #      "network": "udp"
      #    }]
      #  end
      ## 5. 在 route.rules 里，凡是有 inbound 数组的，就追加 "DNS入站_469138946ba5fa"
      #| .route.rules |= map(
      #  if .inbound? and (.inbound | type == "array") then
      #    if any(.inbound[]; . == "DNS入站_469138946ba5fa") then
      #      .
      #    else
      #      .inbound += ["DNS入站_469138946ba5fa"]
      #    end
      #  else
      #    .
      #  end
      #)
      # 6. 去掉 transport.path 里的 ? 之后部分
      | (.outbounds |= map(
        if .transport?.path? then
          .transport.path |= sub("\\\\?.*"; "")
        else
          .
        end
      ))
      ## 7. 删除 TUN入站_469138946ba5fa inbound，并同步清理 route.rules 里的引用
      #| .inbounds |= map(select(.tag != "TUN入站_469138946ba5fa"))
      #| .route.rules |= map(
      #    if .inbound? and (.inbound | type == "array") then
      #      .inbound |= map(select(. != "TUN入站_469138946ba5fa"))
      #    else
      #      .
      #    end
      #)
      # 8. 修复 tuic 节点
      | .outbounds |= map(
          if .type == "tuic" then
            .uuid |= sub("(%3A|:).*"; "")
            | .uuid |= sub("@\\\\[.*\$"; "")
            | .server_port |= (if type=="string" then tonumber else . end)
          else
            .
          end
        )
      ' '${SING_BOX_FILE}' > '${SING_BOX_FILE}.tmp' && mv -fv '${SING_BOX_FILE}.tmp' '${SING_BOX_FILE}'
else
  echo "Error: ${SING_BOX_FILE} is not exist. Exiting."
  exit 3
fi

cp -fv '${SING_BOX_FILE}' '${SING_BOX_FILE}.bak'

# 每个人的系统环境如此的不同
# 假如你原本就有python环境，而我如果写了一个脚本安装python环境，那一定会破坏你原本的python环境
# 所以python环境这块，你自己搭建好吗？
if \$(command -v python3) '${BASE_CONFIG_FIXSCRIPT_FILE}' '${SING_BOX_FILE}.bak' '${SING_BOX_FILE}'; then
  echo ok
else
  cp -fv '${SING_BOX_FILE}.bak' '${SING_BOX_FILE}'
fi

echo "配置已生成: ${SING_BOX_FILE}"

# 配置ip转发
ip_forward() {

  ANCHOR_FILE="/etc/sysctl.d/99-forwarding-singbox.conf"

  # 删除旧规则
  sudo rm -fv \$ANCHOR_FILE

  # 写入规则
  cat <<469138946ba5fa_1 | sudo tee \$ANCHOR_FILE
# /etc/sysctl.d/99-forwarding-singbox.conf
#
# 启用 IPv4 转发
net.ipv4.ip_forward=1

# 启用 IPv6 转发
net.ipv6.conf.all.forwarding=1
net.ipv6.conf.default.forwarding=1

# 接受上游路由通告 (RA)，获取 IPv6 前缀
net.ipv6.conf.all.accept_ra=1
net.ipv6.conf.default.accept_ra=1

# 开启 IPv6 临时地址 (隐私扩展)
net.ipv6.conf.all.use_tempaddr=1
net.ipv6.conf.default.use_tempaddr=1
469138946ba5fa_1

  # 加载并启用 ip 转发
  sudo systemctl restart systemd-sysctl
  sudo sysctl -p

  # 应该能看到 singbox 的规则
  sudo sysctl net.ipv4.ip_forward
  sudo sysctl net.ipv6.conf.all.forwarding
}

ip_forward

# 刷新缓存重启 dnsmasq 当然系统不一定有
sudo systemctl restart dnsmasq || true
sudo resolvectl flush-caches || true

sudo '${SING_BOX_BIN_FILE_RENAME}' -c '${SING_BOX_FILE}' format > '${SING_BOX_FILE}.tmp' && mv -fv '${SING_BOX_FILE}.tmp' '${SING_BOX_FILE}'
sudo pkill -f 'sing-box -D' || true
sudo '${SING_BOX_BIN_FILE_RENAME}' -D '${SING_BOX_DIR}' -c '${SING_BOX_FILE}' run
IFS=\$IFS_BAK
469138946ba5fa

chmod -v a+x ${SING_BOX_START}
echo "已生成启动脚本: ${SING_BOX_START}"

echo "如果想要全局路由你需要配置路由器 DHCP 下发的 Gateway 和 DNS 最好都配置为公共dns比如 8.8.8.8 或 1.1.1.1，不要将 DNS 设置为 172.19.0.1 或 fake-ip 地址"
echo "如果想要旁路由，你需要为单个联网设备配置 Gateway 和 DNS 最好都配置为公共dns比如 8.8.8.8 或 1.1.1.1，不要将 DNS 设置为 172.19.0.1 或 fake-ip 地址"
echo "如果想要端口代理，你需要将联网代理设置为本机 IP:7890"
echo "如果想要本机，那就什么都没什么可说的了"
echo "执行脚本 ${SING_BOX_START} 启动测试看看吧"

IFS=$IFS_BAK
