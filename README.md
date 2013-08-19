framework-bt
============

framework-bt

##TODO:
* エラーケースを洗い出して、対応を実装する
    * notifyの途中で通信が途絶えた場合
    * ackが帰ってこなかった場合に、接続がまだあるかを確認する？
* Centralの開始と終了を明示的に行えるようにする
* Peripheralの開始と終了を明示的に行えるようにする
* ゲームで使うBTの機能を洗い出しして、Frameworkに乗せるかを検討する

##BUG:

##BUG FIX:
* Central 側で Peripheral が見つかっても、didConnectService が呼ばれない事がある
    * タイマーでタイムアウトで error を delegate する
    * Apple 側のバグ（のよう）で、iOS の BT を on -> off する必要がある

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
