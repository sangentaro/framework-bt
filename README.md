framework-bt
============

framework-bt

##TODO:
* Notyficationが受信出来たかどうかを、Central側からPeripheral側に通知する
* ゲームで使うBTの機能を洗い出しして、Frameworkに乗せるかを検討する

##BUG:

##BUG FIX:
* Central 側で Peripheral が見つかっても、didConnectService が呼ばれない事がある
    * タイマーでタイムアウトで error を delegate する
    * Apple 側のバグ（のよう）で、iOS の BT を on -> off する必要がある
