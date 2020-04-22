pod cache clean --all && git tag -d '0.2.0' && git push origin :0.2.0 && git add . && git commit -m "提交" && git push && git tag '0.2.0' && git push --tags && pod repo push WQSpec WQAVPlayer.podspec
