#==============================================================================
# ■ Game_Character (分割定義 1)
#------------------------------------------------------------------------------
# 　キャラクターを扱うクラスです。このクラスは Game_Player クラスと Game_Event
# クラスのスーパークラスとして使用されます。
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :id                       # ID
  attr_reader   :x                        # マップ X 座標 (論理座標)
  attr_reader   :y                        # マップ Y 座標 (論理座標)
  attr_reader   :real_x                   # マップ X 座標 (実座標 * 128)
  attr_reader   :real_y                   # マップ Y 座標 (実座標 * 128)
  attr_reader   :tile_id                  # タイル ID  (0 なら無効)
  attr_reader   :character_name           # キャラクター ファイル名
  attr_reader   :character_hue            # キャラクター 色相
  attr_reader   :opacity                  # 不透明度
  attr_reader   :blend_type               # 合成方法
  attr_reader   :direction                # 向き
  attr_reader   :pattern                  # パターン
  attr_reader   :move_route_forcing       # 移動ルート強制フラグ
  attr_reader   :through                  # すり抜け
  attr_accessor :animation_id             # アニメーション ID
  attr_accessor :transparent              # 透明状態
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    @id = 0
    @x = 0
    @y = 0
    @real_x = 0
    @real_y = 0
    @tile_id = 0
    @character_name = ""
    @character_hue = 0
    @opacity = 255
    @blend_type = 0
    @direction = 2
    @pattern = 0
    @move_route_forcing = false
    @through = false
    @animation_id = 0
    @transparent = false
    @original_direction = 2
    @original_pattern = 0
    @move_type = 0
    @move_speed = 4
    @move_frequency = 6
    @move_route = nil
    @move_route_index = 0
    @original_move_route = nil
    @original_move_route_index = 0
    @walk_anime = true
    @step_anime = false
    @direction_fix = false
    @always_on_top = false
    @anime_count = 0
    @stop_count = 0
    @jump_count = 0
    @jump_peak = 0
    @wait_count = 0
    @locked = false
    @prelock_direction = 0
  end
  #--------------------------------------------------------------------------
  # ● 移動中判定
  #--------------------------------------------------------------------------
  def moving?
    # 論理座標と実座標が違っていれば移動中
    return (@real_x != @x * 128 or @real_y != @y * 128)
  end
  #--------------------------------------------------------------------------
  # ● ジャンプ中判定
  #--------------------------------------------------------------------------
  def jumping?
    # ジャンプカウントが 0 より大きければジャンプ中
    return @jump_count > 0
  end
  #--------------------------------------------------------------------------
  # ● 姿勢の矯正
  #--------------------------------------------------------------------------
  def straighten
    # 移動時アニメまたは停止時アニメが ON の場合
    if @walk_anime or @step_anime
      # パターンを 0 に設定
      @pattern = 0
    end
    # アニメカウントをクリア
    @anime_count = 0
    # ロック前の向きをクリア
    @prelock_direction = 0
  end
  #--------------------------------------------------------------------------
  # ● 移動ルートの強制
  #     move_route : 新しい移動ルート
  #--------------------------------------------------------------------------
  def force_move_route(move_route)
    # オリジナルの移動ルートを保存
    if @original_move_route == nil
      @original_move_route = @move_route
      @original_move_route_index = @move_route_index
    end
    # 移動ルートを変更
    @move_route = move_route
    @move_route_index = 0
    # 移動ルート強制フラグをセット
    @move_route_forcing = true
    # ロック前の向きをクリア
    @prelock_direction = 0
    # ウェイトカウントをクリア
    @wait_count = 0
    # カスタム移動
    move_type_custom
  end
  #--------------------------------------------------------------------------
  # ● 通行可能判定
  #     x : X 座標
  #     y : Y 座標
  #     d : 方向 (0,2,4,6,8)  ※ 0 = 全方向通行不可の場合を判定 (ジャンプ用)
  #--------------------------------------------------------------------------
  def passable?(x, y, d)
    # 新しい座標を求める
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    # 座標がマップ外の場合
    unless $game_map.valid?(new_x, new_y)
      # 通行不可
      return false
    end
    # すり抜け ON の場合
    if @through
      # 通行可
      return true
    end
    # 移動元のタイルから指定方向に出られない場合
    unless $game_map.passable?(x, y, d, self)
      # 通行不可
      return false
    end
    # 移動先のタイルに指定方向から入れない場合
    unless $game_map.passable?(new_x, new_y, 10 - d)
      # 通行不可
      return false
    end
    # 全イベントのループ
    for event in $game_map.events.values
      # イベントの座標が移動先と一致した場合
      if event.x == new_x and event.y == new_y
        # すり抜け OFF なら
        unless event.through
          # 自分がイベントの場合
          if self != $game_player
            # 通行不可
            return false
          end
          # 自分がプレイヤーで、相手のグラフィックがキャラクターの場合
          if event.character_name != ""
            # 通行不可
            return false
          end
        end
      end
    end
    # プレイヤーの座標が移動先と一致した場合
    if $game_player.x == new_x and $game_player.y == new_y
      # すり抜け OFF なら
      unless $game_player.through
        # 自分のグラフィックがキャラクターの場合
        if @character_name != ""
          # 通行不可
          return false
        end
      end
    end
    # 通行可
    return true
  end
  #--------------------------------------------------------------------------
  # ● ロック
  #--------------------------------------------------------------------------
  def lock
    # すでにロックされている場合
    if @locked
      # メソッド終了
      return
    end
    # ロック前の向きを保存
    @prelock_direction = @direction
    # プレイヤーの方を向く
    turn_toward_player
    # ロック中フラグをセット
    @locked = true
  end
  #--------------------------------------------------------------------------
  # ● ロック中判定
  #--------------------------------------------------------------------------
  def lock?
    return @locked
  end
  #--------------------------------------------------------------------------
  # ● ロック解除
  #--------------------------------------------------------------------------
  def unlock
    # ロックされていない場合
    unless @locked
      # メソッド終了
      return
    end
    # ロック中フラグをクリア
    @locked = false
    # 向き固定でない場合
    unless @direction_fix
      # ロック前の向きが保存されていれば
      if @prelock_direction != 0
        # ロック前の向きを復帰
        @direction = @prelock_direction
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 指定位置に移動
  #     x : X 座標
  #     y : Y 座標
  #--------------------------------------------------------------------------
  def moveto(x, y)
    @x = x % $game_map.width
    @y = y % $game_map.height
    @real_x = @x * 128
    @real_y = @y * 128
    @prelock_direction = 0
  end
  #--------------------------------------------------------------------------
  # ● 画面 X 座標の取得
  #--------------------------------------------------------------------------
  def screen_x
    # 実座標とマップの表示位置から画面座標を求める
    return (@real_x - $game_map.display_x + 3) / 4 + 16
  end
  #--------------------------------------------------------------------------
  # ● 画面 Y 座標の取得
  #--------------------------------------------------------------------------
  def screen_y
    # 実座標とマップの表示位置から画面座標を求める
    y = (@real_y - $game_map.display_y + 3) / 4 + 32
    # ジャンプカウントに応じて Y 座標を小さくする
    if @jump_count >= @jump_peak
      n = @jump_count - @jump_peak
    else
      n = @jump_peak - @jump_count
    end
    return y - (@jump_peak * @jump_peak - n * n) / 2
  end
  #--------------------------------------------------------------------------
  # ● 画面 Z 座標の取得
  #     height : キャラクターの高さ
  #--------------------------------------------------------------------------
  def screen_z(height = 0)
    # 最前面に表示フラグが ON の場合
    if @always_on_top
      # 無条件に 999
      return 999
    end
    # 実座標とマップの表示位置から画面座標を求める
    z = (@real_y - $game_map.display_y + 3) / 4 + 32
    # タイルの場合
    if @tile_id > 0
      # タイルのプライオリティ * 32 を足す
      return z + $game_map.priorities[@tile_id] * 32
    # キャラクターの場合
    else
      # 高さが 32 を超えていれば 31 を足す
      return z + ((height > 32) ? 31 : 0)
    end
  end
  #--------------------------------------------------------------------------
  # ● 茂み深さの取得
  #--------------------------------------------------------------------------
  def bush_depth
    # タイルの場合、または最前面に表示フラグが ON の場合
    if @tile_id > 0 or @always_on_top
      return 0
    end
    # ジャンプ中以外で茂み属性のタイルなら 12、それ以外なら 0
    if @jump_count == 0 and $game_map.bush?(@x, @y)
      return 12
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 地形タグの取得
  #--------------------------------------------------------------------------
  def terrain_tag
    return $game_map.terrain_tag(@x, @y)
  end
end
