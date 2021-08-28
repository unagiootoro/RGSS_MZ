#==============================================================================
# ■ Window_Message
#------------------------------------------------------------------------------
# 　文章表示に使うメッセージウィンドウです。
#==============================================================================

class Window_Message < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(80, 304, 480, 160)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.visible = false
    self.z = 9998
    @fade_in = false
    @fade_out = false
    @contents_showing = false
    @cursor_width = 0
    self.active = false
    self.index = -1
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    terminate_message
    $game_temp.message_window_showing = false
    if @input_number_window != nil
      @input_number_window.dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● メッセージ終了処理
  #--------------------------------------------------------------------------
  def terminate_message
    self.active = false
    self.pause = false
    self.index = -1
    self.contents.clear
    # 表示中フラグをクリア
    @contents_showing = false
    # メッセージ コールバックを呼ぶ
    if $game_temp.message_proc != nil
      $game_temp.message_proc.call
    end
    # 文章、選択肢、数値入力に関する変数をクリア
    $game_temp.message_text = nil
    $game_temp.message_proc = nil
    $game_temp.choice_start = 99
    $game_temp.choice_max = 0
    $game_temp.choice_cancel_type = 0
    $game_temp.choice_proc = nil
    $game_temp.num_input_start = 99
    $game_temp.num_input_variable_id = 0
    $game_temp.num_input_digits_max = 0
    # ゴールドウィンドウを開放
    if @gold_window != nil
      @gold_window.dispose
      @gold_window = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    x = y = 0
    @cursor_width = 0
    # 選択肢なら字下げを行う
    if $game_temp.choice_start == 0
      x = 8
    end
    # 表示待ちのメッセージがある場合
    if $game_temp.message_text != nil
      text = $game_temp.message_text
      # 制御文字処理
      begin
        last_text = text.clone
        text = text.gsub(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
      end until text == last_text
      text = text.gsub(/\\[Nn]\[([0-9]+)\]/) do
        $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
      end
      # 便宜上、"\\\\" を "\000" に変換
      text = text.gsub(/\\\\/) { "\000" }
      # "\\C" を "\001" に、"\\G" を "\002" に変換
      text = text.gsub(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
      text = text.gsub(/\\[Gg]/) { "\002" }
      # c に 1 文字を取得 (文字が取得できなくなるまでループ)
      while (true)
        c = text[0]
        text = text[1..-1]
        if c == nil
          break
        end

        # \\ の場合
        if c == "\000"
          # 本来の文字に戻す
          c = "\\"
        end
        # \C[n] の場合
        if c == "\001"
          # 文字色を変更
          text = text.sub(/\[([0-9]+)\]/, "")
          color = $1.to_i
          if color >= 0 and color <= 7
            self.contents.font.color = text_color(color)
          end
          # 次の文字へ
          next
        end
        # \G の場合
        if c == "\002"
          # ゴールドウィンドウを作成
          if @gold_window == nil
            @gold_window = Window_Gold.new
            @gold_window.x = 560 - @gold_window.width
            if $game_temp.in_battle
              @gold_window.y = 192
            else
              @gold_window.y = self.y >= 128 ? 32 : 384
            end
            @gold_window.opacity = self.opacity
            @gold_window.back_opacity = self.back_opacity
          end
          # 次の文字へ
          next
        end
        # 改行文字の場合
        if c == "\n"
          # 選択肢ならカーソルの幅を更新
          if y >= $game_temp.choice_start
            @cursor_width = [@cursor_width, x].max
          end
          # y に 1 を加算
          y += 1
          x = 0
          # 選択肢なら字下げを行う
          if y >= $game_temp.choice_start
            x = 8
          end
          # 次の文字へ
          next
        end
        # 文字を描画
        self.contents.draw_text(4 + x, 32 * y, 40, 32, c)
        # x に描画した文字の幅を加算
        x += self.contents.text_size(c).width
      end
    end
    # 選択肢の場合
    if $game_temp.choice_max > 0
      @item_max = $game_temp.choice_max
      self.active = true
      self.index = 0
    end
    # 数値入力の場合
    if $game_temp.num_input_variable_id > 0
      digits_max = $game_temp.num_input_digits_max
      number = $game_variables[$game_temp.num_input_variable_id]
      @input_number_window = Window_InputNumber.new(digits_max)
      @input_number_window.number = number
      @input_number_window.x = self.x + 8
      @input_number_window.y = self.y + $game_temp.num_input_start * 32
    end
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウの位置と不透明度の設定
  #--------------------------------------------------------------------------
  def reset_window
    if $game_temp.in_battle
      self.y = 16
    else
      case $game_system.message_position
      when 0  # 上
        self.y = 16
      when 1  # 中
        self.y = 160
      when 2  # 下
        self.y = 304
      end
    end
    if $game_system.message_frame == 0
      self.opacity = 255
    else
      self.opacity = 0
    end
    self.back_opacity = 160
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    # フェードインの場合
    if @fade_in
      self.contents_opacity += 24
      if @input_number_window != nil
        @input_number_window.contents_opacity += 24
      end
      if self.contents_opacity == 255
        @fade_in = false
      end
      return
    end
    # 数値入力中の場合
    if @input_number_window != nil
      @input_number_window.update
      # 決定
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        $game_variables[$game_temp.num_input_variable_id] =
          @input_number_window.number
        $game_map.need_refresh = true
        # 数値入力ウィンドウを解放
        @input_number_window.dispose
        @input_number_window = nil
        terminate_message
      end
      return
    end
    # メッセージ表示中の場合
    if @contents_showing
      # 選択肢の表示中でなければポーズサインを表示
      if $game_temp.choice_max == 0
        self.pause = true
      end
      # キャンセル
      if Input.trigger?(Input::B)
        if $game_temp.choice_max > 0 and $game_temp.choice_cancel_type > 0
          $game_system.se_play($data_system.cancel_se)
          $game_temp.choice_proc.call($game_temp.choice_cancel_type - 1)
          terminate_message
        end
      end
      # 決定
      if Input.trigger?(Input::C)
        if $game_temp.choice_max > 0
          $game_system.se_play($data_system.decision_se)
          $game_temp.choice_proc.call(self.index)
        end
        terminate_message
      end
      return
    end
    # フェードアウト中以外で表示待ちのメッセージか選択肢がある場合
    if @fade_out == false and $game_temp.message_text != nil
      @contents_showing = true
      $game_temp.message_window_showing = true
      reset_window
      refresh
      Graphics.frame_reset
      self.visible = true
      self.contents_opacity = 0
      if @input_number_window != nil
        @input_number_window.contents_opacity = 0
      end
      @fade_in = true
      return
    end
    # 表示すべきメッセージがないが、ウィンドウが可視状態の場合
    if self.visible
      @fade_out = true
      self.opacity -= 48
      if self.opacity == 0
        self.visible = false
        @fade_out = false
        $game_temp.message_window_showing = false
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● カーソルの矩形更新
  #--------------------------------------------------------------------------
  def update_cursor_rect
    if @index >= 0
      n = $game_temp.choice_start + @index
      self.cursor_rect.set(8, n * 32, @cursor_width, 32)
    else
      self.cursor_rect.empty
    end
  end
end
