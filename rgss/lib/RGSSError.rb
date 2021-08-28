=begin
RGSSError
RGSS 内部のエラーを通知する例外クラス。

Bitmap クラスや Sprite クラスで、すでに解放したオブジェクトにアクセスしようとしたときなどに発生します。

スーパークラスStandardError 
=end

class RGSSError < StandardError
end
