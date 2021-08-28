#==============================================================================
# ■ Interpreter (分割定義 2)
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_System クラ
# スや Game_Event クラスの内部で使用されます。
#==============================================================================

class Interpreter
  #--------------------------------------------------------------------------
  # ● イベントコマンドの実行
  #--------------------------------------------------------------------------
  def execute_command
    # 実行内容リストの最後に到達した場合
    if @index >= @list.size - 1
      # イベントの終了
      command_end
      # 継続
      return true
    end
    # イベントコマンドのパラメータを @parameters で参照可能に
    @parameters = @list[@index].parameters
    # コマンドコードで分岐
    case @list[@index].code
    when 101  # 文章の表示
      return command_101
    when 102  # 選択肢の表示
      return command_102
    when 402  # [**] の場合
      return command_402
    when 403  # キャンセルの場合
      return command_403
    when 103  # 数値入力の処理
      return command_103
    when 104  # 文章オプション変更
      return command_104
    when 105  # ボタン入力の処理
      return command_105
    when 106  # ウェイト
      return command_106
    when 111  # 条件分岐
      return command_111
    when 411  # それ以外の場合
      return command_411
    when 112  # ループ
      return command_112
    when 413  # 以上繰り返し
      return command_413
    when 113  # ループの中断
      return command_113
    when 115  # イベント処理の中断
      return command_115
    when 116  # イベントの一時消去
      return command_116
    when 117  # コモンイベント
      return command_117
    when 118  # ラベル
      return command_118
    when 119  # ラベルジャンプ
      return command_119
    when 121  # スイッチの操作
      return command_121
    when 122  # 変数の操作
      return command_122
    when 123  # セルフスイッチの操作
      return command_123
    when 124  # タイマーの操作
      return command_124
    when 125  # ゴールドの増減
      return command_125
    when 126  # アイテムの増減
      return command_126
    when 127  # 武器の増減
      return command_127
    when 128  # 防具の増減
      return command_128
    when 129  # アクターの入れ替え
      return command_129
    when 131  # ウィンドウスキンの変更
      return command_131
    when 132  # バトル BGM の変更
      return command_132
    when 133  # バトル終了 ME の変更
      return command_133
    when 134  # セーブ禁止の変更
      return command_134
    when 135  # メニュー禁止の変更
      return command_135
    when 136  # エンカウント禁止の変更
      return command_136
    when 201  # 場所移動
      return command_201
    when 202  # イベントの位置設定
      return command_202
    when 203  # マップのスクロール
      return command_203
    when 204  # マップの設定変更
      return command_204
    when 205  # フォグの色調変更
      return command_205
    when 206  # フォグの不透明度変更
      return command_206
    when 207  # アニメーションの表示
      return command_207
    when 208  # 透明状態の変更
      return command_208
    when 209  # 移動ルートの設定
      return command_209
    when 210  # 移動完了までウェイト
      return command_210
    when 221  # トランジション準備
      return command_221
    when 222  # トランジション実行
      return command_222
    when 223  # 画面の色調変更
      return command_223
    when 224  # 画面のフラッシュ
      return command_224
    when 225  # 画面のシェイク
      return command_225
    when 231  # ピクチャの表示
      return command_231
    when 232  # ピクチャの移動
      return command_232
    when 233  # ピクチャの回転
      return command_233
    when 234  # ピクチャの色調変更
      return command_234
    when 235  # ピクチャの消去
      return command_235
    when 236  # 天候の設定
      return command_236
    when 241  # BGM の演奏
      return command_241
    when 242  # BGM のフェードアウト
      return command_242
    when 245  # BGS の演奏
      return command_245
    when 246  # BGS のフェードアウト
      return command_246
    when 247  # BGM / BGS の記憶
      return command_247
    when 248  # BGM / BGS の復帰
      return command_248
    when 249  # ME の演奏
      return command_249
    when 250  # SE の演奏
      return command_250
    when 251  # SE の停止
      return command_251
    when 301  # バトルの処理
      return command_301
    when 601  # 勝った場合
      return command_601
    when 602  # 逃げた場合
      return command_602
    when 603  # 負けた場合
      return command_603
    when 302  # ショップの処理
      return command_302
    when 303  # 名前入力の処理
      return command_303
    when 311  # HP の増減
      return command_311
    when 312  # SP の増減
      return command_312
    when 313  # ステートの変更
      return command_313
    when 314  # 全回復
      return command_314
    when 315  # EXP の増減
      return command_315
    when 316  # レベルの増減
      return command_316
    when 317  # パラメータの増減
      return command_317
    when 318  # スキルの増減
      return command_318
    when 319  # 装備の変更
      return command_319
    when 320  # アクターの名前変更
      return command_320
    when 321  # アクターのクラス変更
      return command_321
    when 322  # アクターのグラフィック変更
      return command_322
    when 331  # エネミーの HP 増減
      return command_331
    when 332  # エネミーの SP 増減
      return command_332
    when 333  # エネミーのステート変更
      return command_333
    when 334  # エネミーの出現
      return command_334
    when 335  # エネミーの変身
      return command_335
    when 336  # エネミーの全回復
      return command_336
    when 337  # アニメーションの表示
      return command_337
    when 338  # ダメージの処理
      return command_338
    when 339  # アクションの強制
      return command_339
    when 340  # バトルの中断
      return command_340
    when 351  # メニュー画面の呼び出し
      return command_351
    when 352  # セーブ画面の呼び出し
      return command_352
    when 353  # ゲームオーバー
      return command_353
    when 354  # タイトル画面に戻す
      return command_354
    when 355  # スクリプト
      return command_355
    else      # その他
      return true
    end
  end
  #--------------------------------------------------------------------------
  # ● イベントの終了
  #--------------------------------------------------------------------------
  def command_end
    # 実行内容リストをクリア
    @list = nil
    # メインのマップイベント かつ イベント ID が有効の場合
    if @main and @event_id > 0
      # イベントのロックを解除
      $game_map.events[@event_id].unlock
    end
  end
  #--------------------------------------------------------------------------
  # ● コマンドスキップ
  #--------------------------------------------------------------------------
  def command_skip
    # インデントを取得
    indent = @list[@index].indent
    # ループ
    loop do
      # 次のイベントコマンドが同レベルのインデントの場合
      if @list[@index+1].indent == indent
        # 継続
        return true
      end
      # インデックスを進める
      @index += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● キャラクターの取得
  #     parameter : パラメータ
  #--------------------------------------------------------------------------
  def get_character(parameter)
    # パラメータで分岐
    case parameter
    when -1  # プレイヤー
      return $game_player
    when 0  # このイベント
      events = $game_map.events
      return events == nil ? nil : events[@event_id]
    else  # 特定のイベント
      events = $game_map.events
      return events == nil ? nil : events[parameter]
    end
  end
  #--------------------------------------------------------------------------
  # ● 操作する値の計算
  #     operation    : 操作
  #     operand_type : オペランドタイプ (0:定数 1:変数)
  #     operand      : オペランド (数値または変数 ID)
  #--------------------------------------------------------------------------
  def operate_value(operation, operand_type, operand)
    # オペランドを取得
    if operand_type == 0
      value = operand
    else
      value = $game_variables[operand]
    end
    # 操作が [減らす] の場合は符号を反転
    if operation == 1
      value = -value
    end
    # value を返す
    return value
  end
end
