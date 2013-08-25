framework-bt
============

framework-bt

##TODO:
* Centralの開始と終了を明示的に行えるようにする
* Peripheralが特定Centralと接続を継続しているかをPollingによって定期的に確認する
* Threading modelを考える

##BUG:

##BUG FIX:
* Central 側で Peripheral が見つかっても、didConnectService が呼ばれない事がある
    * タイマーでタイムアウトで error を delegate する
    * Apple 側のバグ（のよう）で、iOS の BT を on -> off する必要がある

##Public APIs
```html
- (id) initWithDelegate:(id<RMBTPeripheralDelegate>)delegate peripheralId:(NSString*)peripheralId;
```



##Other Information
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
