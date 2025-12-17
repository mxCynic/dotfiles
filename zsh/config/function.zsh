# python go to visiual environment
pe () {
  if [ -f "pyvenv.cfg" ]; then
    source bin/activate
  else
    if [ -f ".venv/pyvenv.cfg" ]; then 
      source .venv/bin/activate
    else
    echo "No visiual environment"
    fi
  fi
}

# 替换两个文件的名字，保持内容不变
swap() {
  local file1="$1"
  local file2="$2"
  local tmp="$(mktemp )"
  rm -f "$tmp"

  mv "$file1" "$tmp"
  mv "$file2" "$file1"
  mv "$tmp" "$file2"
}

# 连上星界云,控制alas
alas() {
  adb connect 103.36.202.5:499
  adb -s 103.36.202.5:499 forward tcp:7070 tcp:8080
}

spro(){
 export http_proxy=socks5://127.0.0.1:7891
 export https_proxy=socks5://127.0.0.1:7891
}

hpro(){
 export http_proxy=http://127.0.0.1:7891
 export https_proxy=https://127.0.0.1:7891
}

upro(){
 export http_proxy=
 export https_proxy=
 export ALL_PROXY=
}

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= \read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

