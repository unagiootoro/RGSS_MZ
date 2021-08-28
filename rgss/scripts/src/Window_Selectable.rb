#==============================================================================
# ■ Window_Selectable
#------------------------------------------------------------------------------
# 　カーソルの移動やスクロールの機能を持つウィンドウクラスです。
#==============================================================================

class Window_Selectable < Window_Base
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :index                    # カーソル位置
  attr_reader   :help_window              # ヘルプウィンドウ
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     x      : ウィンドウの X 座標
  #     y      : ウィンドウの Y 座標
  #     width  : ウィンドウの幅
  #     height : ウィンドウの高さ
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item_max = 1
    @column_max = 1
    @index = -1
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置の設定
  #     index : 新しいカーソル位置
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    # ヘルプテキストを更新 (update_help は継承先で定義される)
    if self.active and @help_window != nil
      update_help
    end
    # カーソルの矩形を更新
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # ● 行数の取得
  #--------------------------------------------------------------------------
  def row_max
    # 項目数と列数から行数を算出
    return (@item_max + @column_max - 1) / @column_max
  end
  #--------------------------------------------------------------------------
  # ● 先頭の行の取得
  #--------------------------------------------------------------------------
  def top_row
    # ウィンドウ内容の転送元 Y 座標を、1 行の高さ 32 で割る
    return self.oy / 32
  end
  #--------------------------------------------------------------------------
  # ● 先頭の行の設定
  #     row : 先頭に表示する行
  #--------------------------------------------------------------------------
  def top_row=(row)
    # row が 0 未満の場合は 0 に修正
    if row < 0
      row = 0
    end
    # row が row_max - 1 超の場合は row_max - 1 に修正
    if row > row_max - 1
      row = row_max - 1
    end
    # row に 1 行の高さ 32 を掛け、ウィンドウ内容の転送元 Y 座標とする
    self.oy = row * 32
  end
  #--------------------------------------------------------------------------
  # ● 1 ページに表示できる行数の取得
  #--------------------------------------------------------------------------
  def page_row_max
    # ウィンドウの高さから、フレームの高さ 32 を引き、1 行の高さ 32 で割る
    return (self.height - 32) / 32
  end
  #--------------------------------------------------------------------------
  # ● 1 ページに表示できる項目数の取得
  #--------------------------------------------------------------------------
  def page_item_max
    # 行数 page_row_max に 列数 @column_max を掛ける
    return page_row_max * @column_max
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの設定
  #     help_window : 新しいヘルプウィンドウ
  #--------------------------------------------------------------------------
  def help_window=(help_window)
    @help_window = help_window
    # ヘルプテキストを更新 (update_help は継承先で定義される)
    if self.active and @help_window != nil
      update_help
    end
  end
  #--------------------------------------------------------------------------
  # ● カーソルの矩形更新
  #--------------------------------------------------------------------------
  def update_cursor_rect
    # カーソル位置が 0 未満の場合
    if @index < 0
      self.cursor_rect.empty
      return
    end
    # 現在の行を取得
    row = @index / @column_max
    # 現在の行が、表示されている先頭の行より前の場合
    if row < self.top_row
      # 現在の行が先頭になるようにスクロール
      self.top_row = row
    end
    # 現在の行が、表示されている最後尾の行より後ろの場合
    if row > self.top_row + (self.page_row_max - 1)
      # 現在の行が最後尾になるようにスクロール
      self.top_row = row - (self.page_row_max - 1)
    end
    # カーソルの幅を計算
    cursor_width = self.width / @column_max - 32
    # カーソルの座標を計算
    x = @index % @column_max * (cursor_width + 32)
    y = @index / @column_max * 32 - self.oy
    # カーソルの矩形を更新
    self.cursor_rect.set(x, y, cursor_width, 32)
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    # カーソルの移動が可能な状態の場合
    if self.active and @item_max > 0 and @index >= 0
      # 方向ボタンの下が押された場合
      if Input.repeat?(Input::DOWN)
        # 列数が 1 かつ 方向ボタンの下の押下状態がリピートでない場合か、
        # またはカーソル位置が(項目数 - 列数)より前の場合
        if (@column_max == 1 and Input.trigger?(Input::DOWN)) or
           @index < @item_max - @column_max
          # カーソルを下に移動
          $game_system.se_play($data_system.cursor_se)
          @index = (@index + @column_max) % @item_max
        end
      end
      # 方向ボタンの上が押された場合
      if Input.repeat?(Input::UP)
        # 列数が 1 かつ 方向ボタンの上の押下状態がリピートでない場合か、
        # またはカーソル位置が列数より後ろの場合
        if (@column_max == 1 and Input.trigger?(Input::UP)) or
           @index >= @column_max
          # カーソルを上に移動
          $game_system.se_play($data_system.cursor_se)
          @index = (@index - @column_max + @item_max) % @item_max
        end
      end
      # 方向ボタンの右が押された場合
      if Input.repeat?(Input::RIGHT)
        # 列数が 2 以上で、カーソル位置が(項目数 - 1)より前の場合
        if @column_max >= 2 and @index < @item_max - 1
          # カーソルを右に移動
          $game_system.se_play($data_system.cursor_se)
          @index += 1
        end
      end
      # 方向ボタンの左が押された場合
      if Input.repeat?(Input::LEFT)
        # 列数が 2 以上で、カーソル位置が 0 より後ろの場合
        if @column_max >= 2 and @index > 0
          # カーソルを左に移動
          $game_system.se_play($data_system.cursor_se)
          @index -= 1
        end
      end
      # R ボタンが押された場合
      if Input.repeat?(Input::R)
        # 表示されている最後尾の行が、データ上の最後の行よりも前の場合
        if self.top_row + (self.page_row_max - 1) < (self.row_max - 1)
          # カーソルを 1 ページ後ろに移動
          $game_system.se_play($data_system.cursor_se)
          @index = [@index + self.page_item_max, @item_max - 1].min
          self.top_row += self.page_row_max
        end
      end
      # L ボタンが押された場合
      if Input.repeat?(Input::L)
        # 表示されている先頭の行が 0 より後ろの場合
        if self.top_row > 0
          # カーソルを 1 ページ前に移動
          $game_system.se_play($data_system.cursor_se)
          @index = [@index - self.page_item_max, 0].max
          self.top_row -= self.page_row_max
        end
      end
    end
    # ヘルプテキストを更新 (update_help は継承先で定義される)
    if self.active and @help_window != nil
      update_help
    end
    # カーソルの矩形を更新
    update_cursor_rect
  end
end
