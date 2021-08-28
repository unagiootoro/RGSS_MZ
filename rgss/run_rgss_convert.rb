require_relative "rgss_convertor"

#引数１でScriptsファイルのあるディレクトリを指定
#引数２でscriptsディレクトリのあるディレクトリを指定
#引数３でScriptsの拡張子を指定
cvtr = RGSS_Convertor.new(".", ".", "rxdata")

#ScriptsファイルをRubyファイルに変換する場合
cvtr.to_text

#scriptsディレクトリ内のRubyファイルからScriptsファイルを作成場合
cvtr.to_bin
