# Battery Time

又一个查看电池剩余使用时间的状态栏小程序。

![截图](./screenshot.png)

### 下载

访问 [Releases](https://github.com/venj/Battery-Time/releases/) 页面，或 [点此下载](https://github.com/venj/Battery-Time/releases/download/1.2/BatteryTime.zip)。

### 关闭登录时启动

开启App后，执行：

```
defaults write ~/Library/Containers/me.venj.Battery-Time/Data/Library/Preferences/me.venj.Battery-Time DisableStartUpAtLogin -bool YES && killall cfprefsd
```

退出App，再次启动可生效。

## License

MIT
