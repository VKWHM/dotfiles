# Copy file from kali container to local
function cf() {
    local src=$1;
    local dst=$2;
    if [ -z $src ] || [ -z $dst ]; then
        echo "Usage: ct <remote source> <local destination>"
        return 1
    fi
    rsync -ave 'ssh -p 55000' attacker@localhost:$src $dst
}

# Copy file from local to kali container
function ct() {
    local src=$1;
    local dst=$2;
    if [ -z $src ] || [ -z $dst ]; then
        echo "Usage: ct <local source> <remote destination>"
        return 1
    fi
    rsync -ave 'ssh -p 55000' $src attacker@localhost:$dst
}

# Docker create kali container function
function skc() {
    local name="$(echo -e $1 | tr -d '[:space:]')";
    shift;
    if [ -z $name ]; then
        echo "Usage: skc <container name> [<docker run options>]";
        return 1;
    fi
    docker run -dtP --rm --expose 22 -p 4445:4445 -p 4444:4444 -p 53:53 $@ --name "$name" --hostname "$name" -v kali-usr:/usr -v kali-var:/var -v kali-etc:/etc -v kali-attacker:/home/attacker kalilinux/kali-rolling /bin/bash && docker exec -u root $name /usr/local/sbin/startup;
    echo "Container '$name' is running. You can connect via ssh $(docker port $name 22 | cut -d ":" -f 2) port.";
}

# find or create build directory and build cmake project
# Find or create build directory and build cmake project
build() {
  local variable=true

  # Check if a 'build' directory exists
  for file in $(ls); do 
    if [ "$file" = "build" ]; then
      cd "$file" || return 1
      break
    fi
  done

  # If in 'build' directory, clean and rebuild
  if [ "$(basename "$(pwd)")" = "build" ]; then
    local files=$(ls)
    if [ -n "$files" ]; then
      for file in $(ls); do 
        rm -rf "$file"
      done
    fi
    variable=false
  else
    # Check if the current directory has CMakeLists.txt
    for file in $(ls); do
      if [ "$file" = "CMakeLists.txt" ]; then
        mkdir -p build
        cd build || return 1
        variable=false
        break
      fi
    done
    # No CMakeLists.txt found
    if $variable; then
      echo "[-] $(pwd) does not contain CMakeLists.txt!"
      return 1
    else
      cmake .. || { echo "[-] CMake configuration failed!"; return 1; }
      make || { echo "[-] Make failed!"; return 1; }
    fi
  fi
}

# Get operation system type
get_ostype ()
{
  case "$OSTYPE" in
    "darwin"*) echo "darwin" ;;
    *) echo "linux" ;;
  esac
}

# System appearance type
is_dark ()
{
  if [[ "$(get_ostype)" == "darwin" ]]; then
    defaults read -globalDomain AppleInterfaceStyle | grep -qE '^Dark'
    return $? # 1 => light, 0 => dark
  elif [[ ! -z "$WHM_APPEARANCE" ]]; then
    [[ "$WHM_APPEARANCE" == "Dark"* ]]  
    return $?
  else
    return 0
  fi
}

# Extract archive dynamicly
extract() {
  if [ -z "$1" ]; then
    echo "Usage: extract <file name>.<> ..."
    return 1
  fi

  for n in $@
  do
    if [ -f "$n" ]; then
      filepath="$(readlink -f "$n")"
      case "$n" in
        *.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
          tar xvf "$filepath" ;;
        *.lzma)
          unlzma "$filepath" ;;
        *.bz2)
          bunzip2 "$filepath" ;;
        *.rar)
          unrar x -ad "$filepath" ;;
        *.gz)
          gunzip "$filepath" ;;
        *.zip)
          unzip "$filepath" ;;
        *.z)
          uncompress "$filepath" ;;
        *.7z|*.arj|*.cab|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.rpm|*.udf|*.wim|*.xar)
          7z x "$filepath" ;;
        *.xz)
          unxz "$filepath" ;;
        *)
          echo "[-] extract: '$n' - unknown archive method"
          return 1
          ;;
      esac
    else
      echo "[-] '$n' - file does not exist"
      return 1
    fi
  done
}

check_path() {
  [[ ":$PATH:" == *":$1:"* ]];
  return $?
}

export_path() {
  if ! check_path "$1"; then
    export PATH="$PATH:$1"
  fi
}

appendpath() {
  if [ -z "$1" ]; then
    echo "Usage: appendpath <path>"
    return 1
  fi

  if ! check_path "$1"; then
    echo "[*] '$1' adding to PATH"
    export PATH="$PATH:$1"
    if grep -qE "^export PATH=.*$1" ~/.zshrc; then
      echo "[*] '$1' already exists in .zshrc"
    else
      echo "export PATH=\$PATH:$1" >> ~/.zshrc
      echo "[+] '$1' added to .zshrc"
    fi
  fi
}

_ask_copilot_explain ()
{
  local prompt="${BUFFER:0:$CURSOR}"
  gh copilot explain "$prompt"
  zle redisplay
}
