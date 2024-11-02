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
# TODO: Fix build function
build () {
  variable = true;
  for file in $(ls);
  do 
    if [ "$file" = "build" ]; then
      cd "$file";
      break;
    fi
  done
  if [ $(basename "$(pwd)") = "build" ]; then
    local file="$(ls)";
    if [ "${#file[@]}" != "0" ]; then
      for file in $(ls);
      do 
        rm -rf "$file";
      done
    fi
    cmake ..;
    make 
    variable = false;
  else
    for file in $(ls);
    do
      if [ "$file" = "CMakeList.txt" ]; then
        mkdir build;
        build;
        variable = false;
        break;
      fi
    done
    if [ "variable" = true ]; then
      echo "[-] $(pwd) is not has CMakeLists.txt!";
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
  else
    return 0
  fi
}
