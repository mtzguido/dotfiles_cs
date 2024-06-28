#!/bin/bash

alias ls="ls --color=auto --group-directories-first -v"
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# ask please !
alias pls='sudo $(history -p !-1)'

CORES=$(nproc)

alias l1="ls -1F"
alias la="ls -A"
alias ll="ls -l"
alias l="ls -F"

alias o=xdg-open

if [ $(id -u) -eq 0 ]; then
	startu=$(tput setaf 1)
	symb='#'
else
	startu=$(tput setaf 2)
	symb='$'
fi

if ! [ -z "$SSH_CONNECTION" ]; then
	starth=$(tput setab 1; tput bold)
else
	starth=$(tput sgr0)
fi

endu=$(tput sgr0)
endh=$(tput sgr0)

archs=$(tput setaf 1)
arche=$(tput sgr0)

# __g_show_arch=$(if ! [ -z "$ARCHMSG" ]; then echo "($ARCHMSG)"; fi)
__g_show_branch='BR=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); if [ $? -eq 0 ]; then echo "($BR)"; fi'
# PS1="\[${startu}\]\u\[${endu}\]@\[${starth}\]\h\[${endh}\]:\w\[$archs\]\$__g_show_arch\$($__g_show_branch)\[$arche\]\$ "
PS1="\[${startu}\]\u\[${endu}\]@\[${starth}\]\h\[${endh}\]:\w\[$archs\]\$($__g_show_branch)\[$arche\]\$ "

protect_bg_jobs()
{
	if [ "$(jobs)" == "" ]; then
		set +o ignoreeof
	else
		export IGNOREEOF=9999
	fi
}
PROMPT_COMMAND=protect_bg_jobs

x () {
	startx
}

j () {
	cd "$(readlink -f "$HOME/.marks/$1")"
}

mark () {
	if ! [ -d "$HOME/.marks" ]; then
		mkdir "$HOME/.marks"
	fi

	ln -Tfs "$(pwd)" "$HOME/.marks/$1"
}

unmark () {
	rm "$HOME/.marks/$1"
}

__comp_jump () {
	local cur
	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	if [ -d "$HOME/.marks" ]; then
		COMPREPLY=( $(compgen -W "$(ls "$HOME/.marks")" -- "$cur") )
	else
		COMPREPLY=()
	fi
}

complete -F __comp_jump j
complete -F __comp_jump mark
complete -F __comp_jump unmark

__comp_magic () {
	local cur
	local PROG
	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	PROG=${COMP_WORDS[0]}

	if [[ "$PROG" == ~* ]]; then
		PROG="$HOME/${PROG:1}"
	fi

	PROG=$(which "$PROG")

	if [[ "$cur" == -* ]] && [ -x "$PROG" ]; then
		CACHEFILE="$HOME/.magic_comp/$(realpath $PROG)"
		if [ -f "$CACHEFILE" ] && [ "$CACHEFILE" -nt "$PROG" ]; then
			OPTS="$(cat $CACHEFILE)"
		else
			mkdir -p $(dirname $CACHEFILE)
			OPTS=$(${PROG} ${MAGIC_COMP_OPTS} |& grep -Eo -- "--[^=,;#/()\`.'\" ]*" | tee $CACHEFILE)
		fi
		COMPREPLY=( $(compgen -W "$OPTS" -- "$cur") )
	else
		COMPREPLY=( $(compgen -f -- "$cur") )
	fi
}
__comp_ghc () {
	local MAGIC_COMP_OPTS=--show-options
	__comp_magic
}
__comp_ice () {
	local MAGIC_COMP_OPTS=--help
	__comp_magic
}
complete -o filenames -F __comp_magic fstar.exe
complete -o filenames -F __comp_magic fstar-any.sh
complete -o filenames -F __comp_magic fstar
complete -o filenames -F __comp_magic tests.exe
complete -o filenames -F __comp_magic cmt
complete -o filenames -F __comp_magic agda
complete -o filenames -F __comp_ice ice
complete -o filenames -F __comp_ghc ghc

# Vim tags autocompletion
__vim_ctags() {
	local cur prev

	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	case "${prev}" in
		-t)
			# Avoid the complaint message when no tags file exists
			if [ ! -r ./tags ]
			then
				return
			fi

			# Escape slashes to avoid confusing awk
			cur=${cur////\\/}

			COMPREPLY=( $(compgen -W "`awk -v ORS=" "  "/^${cur}/ { print \\$1 }" tags`" ) )
			;;
		*)
			# Perform usual completion mode
			;;
	esac
}
# Files matching this pattern are excluded
excludelist='*.@(o|O|so|SO|so.!(conf)|SO.!(CONF)|a|A|rpm|RPM|deb|DEB|gif|GIF|jp?(e)g|JP?(E)G|mp3|MP3|mp?(e)g|MP?(E)G|avi|AVI|asf|ASF|ogg|OGG|class|CLASS)'
complete -F __vim_ctags -f -X "${excludelist}" vi vim gvim rvim view rview rgvim rgview gview

mus () {
	cd "$HOME"/media/music && exec screen -qdRR music cmus
}

add_to_path () {
	DIR=$1

	if [ "$DIR" != "/" ] && [ "${DIR:(-1)}" == "/" ]; then
		DIR=${DIR:0:${#DIR}-1}
	fi

	if [ "$PATH" == "" ]; then
		PATH=$DIR
		return
	fi

	if [ -d "$DIR" ] && ! [[ ":$PATH:" == *":$DIR:"* ]]; then
		PATH="$DIR:$PATH"
	fi
}

rem_from_path () {
	FAKEPATH=":$PATH:"
	DIR=$1

	if [ "$DIR" != "/" ] && [ "${DIR:(-1)}" == "/" ]; then
		DIR=${DIR:0:${#DIR}-1}
	fi

	while [[ "$FAKEPATH" == *":$DIR:"* ]]; do
		FAKEPATH=${FAKEPATH/$DIR:/}
	done

	if [ "$FAKEPATH" == ":" ]; then
		PATH=
	else
		PATH=${FAKEPATH:1:${#FAKEPATH}-2}
	fi
}

add_to_path "$HOME/bin"
add_to_path "$HOME/.local/bin"
add_to_path "/sbin"
add_to_path "/usr/sbin"
add_to_path "$HOME/.cabal/bin"
# add_to_path "$HOME/bin/OpenCilk-10.0.1-Linux/bin"

if [ -z "$LS_COLORS" ] && [ -x /usr/bin/dircolors ]; then
	eval $(dircolors)
fi

super-upgrade () {
	sudo apt update &&
	sudo apt dist-upgrade &&
	sudo apt autoremove --purge #&&
	sudo apt clean
}

syslog () {
	tail -n+0 -f /var/log/syslog
}

tar-list-perms () {
	tar tvf "$1" | awk ' { print $1 "\t" $6 }' | sort | less
}

alias tstamp="ts -s \"[%H:%M:%.S]\""

usage () {
	du -ahx "$@" | sort -h
}

llog () {
	lastlog | grep -Ev '(Never logged in|Username)' | sort -k9,9n -k5,5M -k6,6n -k7,7
}

tag () {
	ctags -Ra ${1:-.}
}

htag () {
	find . | egrep '\.hs$' | xargs hothasktags > tags
}

gclean () {
	git clean -e tags -e texdirectives.tex -dfx "$@"
}

export ANDROID_HOME=/opt/android-sdk-linux

ifrestart () {
	sudo ifdown $1 && sudo ifup $1
}

promm-get-db () {
	ssh -t promm mysqldump -u root -p prommdb | mysql -u root -p prommdb
}

xopen () {
	for i in "$@"; do
		xdg-open "$i"
	done
}

gdiff () {
	git diff --no-index "$@"
}

gsdiff () {
	sdiff -w $COLUMNS "$@" | colordiff | less -R
}

xdiff () {
	if [ $# -ge 2 ]; then
		sdiff -s <(xxd "$1") <(xxd "$2") | colordiff | less -R
	fi
}

xvi () {
	F=$1
	T=$(mktemp)
	xxd $F > $T
	vi $T
	xxd -r $T > $F
}

rebuild-fstar () {
	make -j${CORES} -C src/ && make -C src/ fstar-ocaml -j${CORES}
}
rebuild-fstar-snapshot () {
	make -j${CORES} -C src/ && make -C src/ ocaml -j${CORES}
}

refresh-fstar-module () {
	(
	cd src/
	for i in "$@"; do
		make -n fstar-ocaml | grep -A2 $i$ | tee /dev/tty | bash &
	done
	wait
	) &&
	make
}

alias m="ramon make -j${CORES}"
snap () {
	git add ocaml/fstar*/generated && git commit -m snap
}

home_here () {
	export FSTAR_HOME=$(pwd)
}

hints () {
	find . -name '*.hints' -exec git add {} \+ && git commit -m hints
}

hints-reset () {
	find . -name '*.hints' -exec git reset {} \+ \
		&& find . -name '*.hints' -exec git checkout {} \+
}

hints-mine () {
	find . -name '*.hints' -exec git co HEAD -- {} \+
}

snap-mine () {
	git co HEAD -- src/ocaml-output/*.ml
}

snap-reset () {
	git reset HEAD -- src/ocaml-output/*.ml \
		&& git co HEAD -- src/ocaml-output/*.ml
}

mkb () {
	L=$1
	cat ~/.b.top > b.fst
	for i in $(seq 1 $L); do
		echo "          let x = f x in let x = f x in let x = f x in" >> b.fst
	done
	cat ~/.b.bot >> b.fst
}

mtop () {
	top -o %MEM "$@"
}

highlight () {
	grep -E "$1|"
}

# if which opam &> /dev/null; then
#         eval $(opam config env --safe)
# fi

# Everest exports, with precedence over OPAM
#export PATH=/home/guido/r/fstarr/bin:$PATH
#export PATH=/home/guido/r/everest/kremlin:$PATH

# export FSTAR_HOME=/home/guido/r/fstar/master
# export KRML_HOME=/home/guido/everest/karamel
# export HACL_HOME=/home/guido/r/hacl-star
# export VALE_HOME=/home/guido/r/vale/
# export MLCRYPTO_HOME=/home/guido/r/everest/MLCrypto/
# export QD_HOME=/home/guido/r/everparse

fix-tags () {
	LC_COLLATE=C sort tags -o tags
}

ww () {
	watch -n 0.1 "$@"
}

gsdiff () {
	sdiff -w $COLUMNS "$@" | colordiff | less -R
}

retry () {
	while ! "$@"; do sleep 15; done
}

function job_put() {
	# Just put a token in the pipe
	echo -n X >~/.gjobpipe
}

# Grab a process slot
function job_get() {
	# Just read a character, but careful to retry.
	while ! read -n1 2>/dev/null <~/.gjobpipe; do
		# It can happen that `read` on a pipe returns
		# EAGAIN when a process has the pipe opened
		# for writing but has no written yet. This is
		# avoided by not using O_NONBLOCK, but we don't have
		# access to that here, so just sleep and retry,
		# which is not too bad.
		sleep 1
	done
}

getlog () {
	url=$1
	wget -O L ${url}
	vi L
}

fboot () {
	FSTAR_BOOT=/home/guido/r/fstar/pristine/bin/fstar.exe make 2 -sj$(nproc)
}

qboot () {
	ramon --tee boot.ramon make full-bootstrap -ksj$(nproc) ADMIT=1 |& tee boot.log
}

qfboot () {
	make clean-snapshot &&
	FSTAR_BOOT=/home/guido/r/fstar/pristine/bin/fstar.exe \
	  ramon --tee boot.ramon make bootstrap -ksj$(nproc) ADMIT=1 |& tee boot.log
}

qci () {
	# unset KRML_HOME, don't run karamel tests on this alias
	KRML_HOME= ramon --tee ci.ramon make ci -ksj$(nproc) |& tee ci.log
}

summ () {
	sort "$1" | uniq -c | sort -n
}

emacs_here () {
	D=$(pwd)
	ln -sf ${D}/bin/fstar.exe ~/bin/fstar.exe
	#sed -i '/setq-default fstar-executable/d' ~/.emacs
	#echo "(setq-default fstar-executable \"$D/bin/fstar.exe\")" >> ~/.emacs
}

bitflip () {
	F=$1
	( xxd -p "$F" | tr '0123456789abcdef' 'fedcba9876543210' | xxd -r -p > "$F".flipped ) && mv "$F".flipped "$F"
}

source ~/.everest-build-this.sh

job () {
	unbuffer ramon --tee ramon.log "$@" | tee L
}
