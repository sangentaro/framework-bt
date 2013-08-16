framework-bt
============

framework-bt

##TODO:
* 送信の全データにパケット番号を振る

##BUG:

##BUG FIX:
* Central 側で Peripheral が見つかっても、didConnectService が呼ばれない事がある
    * タイマーでタイムアウトで error を delegate する
    * Apple 側のバグ（のよう）で、iOS の BT を on -> off する必要がある
