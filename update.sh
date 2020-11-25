OP_BACKUP=false
OP_DEPLOY=false

if [ -n "$1" ]; then
	while [ -n "$1" ]
	do
		case "$1" in
		-b|--backup)
			OP_BACKUP=true
			;;
		-d|--deploy)
			OP_DEPLOY=true
			;;
		-a|--all)
			OP_DEPLOY=true
			OP_BACKUP=true
			;;
		-m|--message)
			MSG=$2
			shift 2
			;;
		*)
			echo "illegal option"
			;;
		esac
		shift
	done	
# else
	# echo "deploy & backup $(date "+%Y-%m-%d %H:%M:%S")"
fi
if [ "$OP_BACKUP" = false -a "$OP_DEPLOY" = false ] ; then
	OP_BACKUP=true
	OP_DEPLOY=true
fi

if [ -z "$MSG" ]; then
	if [ "$OP_BACKUP" = true -a "$OP_DEPLOY" = true ]; then
		MSG="[Backup & Deploy] $(date "+%Y-%m-%d %H:%M:%S")"
	elif [ "$OP_BACKUP" = true -a "$OP_DEPLOY" = false ]; then
		MSG="[Backup only] $(date "+%Y-%m-%d %H:%M:%S")"
	fi
fi

# run 
if [ "$OP_BACKUP" = true ]; then
	git checkout hexo
	git add .
	git commit -m "$MSG"
	git push origin hexo
fi
if [ "$OP_DEPLOY" = true ]; then
	hexo clean
	hexo d -g
fi