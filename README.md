framework-bt
============

framework-bt

##TODO:
* Threading modelを考える

##BUG FIX:
* Central 側で Peripheral が見つかっても、didConnectService が呼ばれない事がある
    * タイマーでタイムアウトで error を delegate する
    * Apple 側のバグ（のよう）で、iOS の BT を on -> off する必要がある

##Project Structure
```
├── Framework-iOS
│   ├── Framework-iOS
│   │   ├── Source
│   │   │   ├── BTKit.h
│   │   │   ├── DefConst.h
│   │   │   ├── DefConst.m
│   │   │   ├── NSString+Split.h
│   │   │   ├── NSString+Split.m
│   │   │   ├── RMBTCentral.h
│   │   │   ├── RMBTCentral.m
│   │   │   ├── RMBTPeripheral.h
│   │   │   ├── RMBTPeripheral.m
│   │   │   ├── RMLog.h
│   │   │   └── RMLog.m
│   │   └── Support\ Files
│   ├── Framework-iOS\ APP
│   │   ├── Icons
│   │   ├── Source
│   │   │   ├── Framework_iOSAppDelegate.h
│   │   │   ├── Framework_iOSAppDelegate.m
│   │   │   ├── Framework_iOSViewController.h
│   │   │   └── Framework_iOSViewController.m
│   │   ├── Support\ Files
│   │   └── en.lproj
│   ├── Framework-iOS.xcodeproj
|   └── Products
├── README.md
└── docs
    └── html
        ├── Classes
        ├── css
        ├── hierarchy.html
        ├── img
        └── index.html      <-- Document root
```

##Documents
```
appledoc --project-name AppledocSample --project-company Classmethod --create-html --no-create-docset --output ./docs/ .
```

で`docs`フォルダ以下にドキュメントを生成する

##Usage Information
###RMBTPeripheral
RMBTPeripheralはCoreBTでPeripheral側となるクラス。PeripheralはServer / ClinetモデルにおけるServerを指す。

###RMBTCentral
RMBTCentralはCoreBTでCentral側となるクラス。CentralはServer / ClientモデルにおけるClientを指す。

Peripehralが見つかるとDelegate methodの
```html
  - (void)peripheralFound;
```
が呼ばれる

発見されたPeripheralはRMCBCentralクラスのpropertyである
```html
  (NSMutableArray) peripherals
```
に格納される

Peripheralとは
```html
  - (void) connectToPeripheral:(int)index;
```
Methodで接続する。ここでindexは`peripherals`のindex。
