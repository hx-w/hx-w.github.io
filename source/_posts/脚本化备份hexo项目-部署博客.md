---
title: 脚本化备份hexo项目&部署博客
tags:
  - shell
  - git
category: 教程
abbrlink: d553
date: 2020-11-25 13:16:10
---

## 概述

我习惯了用typora写markdown文件，前几天写博客时突然文件内容全部丢失，找到的最近的备份还是半个小时之前的内容，还是觉得很遗憾。

由于hexo部署博客内容是先在本地将markdown渲染成html再传到github上部署，所以github上是没有博客的原稿markdown内容的。

为了方便移植本地环境，也为了防止文件丢失的事情再次发生，我写了一个shell脚本用来帮助我备份整个hexo项目。

<!--more-->

## 使用备份分支

hexo会将本地编译好的`public/`等文件内容传到对应的github库上，默认使用master分支，且hexo项目里只有`.deploy_git/`文件夹，并不包含`.git/`文件夹，无法直接用git管理版本，所以我就在博客对应的github仓库里新建了一个hexo分支用来备份整个hexo项目内容。

1. 在github上的`<username>.github.io`仓库内新建`hexo`分支

   ![](https://ibed.csgowiki.top/hexo_backup-1.png)

   > 如果你使用了`hexo-blog-encrypt`等博文加密插件，可能不希望某些文章内容被公开，那么你可以选择新建一个私有的github库用来备份hexo项目

2. 在本地其他目录下输入指令`git clone -b hexo https://github.com/<username>/<username>.github.io.git`用来将新的分支clone到本地

3. clone到本地后，将`<username>.github.io/`文件夹下的`.git/`文件复制到**你的hexo项目的根目录下**，clone到本地的文件夹就可以删掉了

4. 将所用主题的`.git`文件删除，即`hexo/themes/<your_theme>/.git/`

   > 社区的主题项目通常也是用git管理，hexo项目的.git与主题的.git嵌套会出问题

5. 在hexo项目下创建并切换新分支`hexo`：`git checkout -b hexo`

6. 创建并更改`.gitignore`文件，忽略hexo自动生成的文件与_config.yml配置文件(可能有秘钥等信息)，内容参考：

   ```
   .DS_Store
   Thumbs.db
   db.json
   *.log
   node_modules/
   public/
   .deploy*/
   _config.yml
   ```

7. 将本地hexo项目强行推送到远端`hexo分支`：`git push origin hexo --force`

完成上述几步操作之后即可查看github上`hexo`分支是否同步了本地的项目，如果操作正确应该是没问题的。

## 脚本化备份与部署

经过上面的操作，我们就可以每次部署博客时先备份项目。为了操作简便，我写了一个简单地shell脚本用来帮助我备份和部署博客项目，代码在文章末尾。

### 注意事项

因为是shell脚本，所以需要gitbash或linux环境。我在本地测试时gitbash和ubuntu(子系统)都可以。

可以将脚本命名为`update.sh`放在hexo项目的根目录下。

使用脚本时需要确保**当前目录是hexo的根目录**，通过`./update.sh`运行脚本。

### 脚本参数

- 无参数：先备份hexo项目，再部署博客，备份项目时提交信息为"[Backup & Depoly] <日期: 时间>"。
- `-a`或`--all`：先备份hexo项目，再部署博客，备份项目的提交信息如果没有`-m`指定，那么会自动生成为"[Backup & Deploy] <日期: 时间>"。
- `-b`或`--backup`：只进行备份hexo项目的功能，如果没有指定提交信息，则自动生成"[Backup] <日期: 时间>"。
- `-d`或`--deploy`：只部署博客。
- `-m`或`--message`：后接参数表示提交信息，用于指定备份hexo项目时的提交信息。

### 脚本内容

> [update.sh](/static/update.sh)

```bash
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
			exit 1
			;;
		esac
		shift
	done	
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
	# 备份hexo项目
	git checkout hexo
	git add .
	git commit -m "$MSG"
	git push origin hexo
fi
if [ "$OP_DEPLOY" = true ]; then
	# 部署博客内容
	hexo clean
	hexo d -g
fi
```



