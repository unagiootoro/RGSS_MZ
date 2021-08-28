#==============================================================================
# ■ Game_Map
#------------------------------------------------------------------------------
# 　マップを扱うクラスです。スクロールや通行可能判定などの機能を持っています。
# このクラスのインスタンスは $game_map で参照されます。
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :tileset_name             # タイルセット ファイル名
  attr_accessor :autotile_names           # オートタイル ファイル名
  attr_accessor :panorama_name            # パノラマ ファイル名
  attr_accessor :panorama_hue             # パノラマ 色相
  attr_accessor :fog_name                 # フォグ ファイル名
  attr_accessor :fog_hue                  # フォグ 色相
  attr_accessor :fog_opacity              # フォグ 不透明度
  attr_accessor :fog_blend_type           # フォグ ブレンド方法
  attr_accessor :fog_zoom                 # フォグ 拡大率
  attr_accessor :fog_sx                   # フォグ SX
  attr_accessor :fog_sy                   # フォグ SY
  attr_accessor :battleback_name          # バトルバック ファイル名
  attr_accessor :display_x                # 表示 X 座標 * 128
  attr_accessor :display_y                # 表示 Y 座標 * 128
  attr_accessor :need_refresh             # リフレッシュ要求フラグ
  attr_reader   :passages                 # 通行 テーブル
  attr_reader   :priorities               # プライオリティ テーブル
  attr_reader   :terrain_tags             # 地形タグ テーブル
  attr_reader   :events                   # イベント
  attr_reader   :fog_ox                   # フォグ 原点 X 座標
  attr_reader   :fog_oy                   # フォグ 原点 Y 座標
  attr_reader   :fog_tone                 # フォグ 色調
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    @map_id = 0
    @display_x = 0
    @display_y = 0
  end
  #--------------------------------------------------------------------------
  # ● セットアップ
  #     map_id : マップ ID
  #--------------------------------------------------------------------------
  def setup(map_id)
    # マップ ID を @map_id に記憶
    @map_id = map_id
    # マップをファイルからロードし、@map に設定
    if RUBY_ENGINE == "opal"
      @map = load_data(sprintf("rgss/converted/Map%03d.json", @map_id))
    else
      if RGSS_ENABLE_MARSHAL
        @map = load_data(sprintf("Data/Map%03d.rxdata", @map_id))
      else
        @map = load_data(sprintf("rgss/converted/Map%03d.json", @map_id))
      end
    end
    # 公開インスタンス変数にタイルセットの情報を設定
    tileset = $data_tilesets[@map.tileset_id]
    @tileset_name = tileset.tileset_name
    @autotile_names = tileset.autotile_names
    @panorama_name = tileset.panorama_name
    @panorama_hue = tileset.panorama_hue
    @fog_name = tileset.fog_name
    @fog_hue = tileset.fog_hue
    @fog_opacity = tileset.fog_opacity
    @fog_blend_type = tileset.fog_blend_type
    @fog_zoom = tileset.fog_zoom
    @fog_sx = tileset.fog_sx
    @fog_sy = tileset.fog_sy
    @battleback_name = tileset.battleback_name
    @passages = tileset.passages
    @priorities = tileset.priorities
    @terrain_tags = tileset.terrain_tags
    # 表示座標を初期化
    @display_x = 0
    @display_y = 0
    # リフレッシュ要求フラグをクリア
    @need_refresh = false
    # マップイベントのデータを設定
    @events = {}
    for i in @map.events.keys
      @events[i] = Game_Event.new(@map_id, @map.events[i])
    end
    # コモンイベントのデータを設定
    @common_events = {}
    for i in 1...$data_common_events.size
      @common_events[i] = Game_CommonEvent.new(i)
    end
    # フォグの各情報を初期化
    @fog_ox = 0
    @fog_oy = 0
    @fog_tone = Tone.new(0, 0, 0, 0)
    @fog_tone_target = Tone.new(0, 0, 0, 0)
    @fog_tone_duration = 0
    @fog_opacity_duration = 0
    @fog_opacity_target = 0
    # スクロール情報を初期化
    @scroll_direction = 2
    @scroll_rest = 0
    @scroll_speed = 4
  end
  #--------------------------------------------------------------------------
  # ● マップ ID の取得
  #--------------------------------------------------------------------------
  def map_id
    return @map_id
  end
  #--------------------------------------------------------------------------
  # ● 幅の取得
  #--------------------------------------------------------------------------
  def width
    return @map.width
  end
  #--------------------------------------------------------------------------
  # ● 高さの取得
  #--------------------------------------------------------------------------
  def height
    return @map.height
  end
  #--------------------------------------------------------------------------
  # ● エンカウントリストの取得
  #--------------------------------------------------------------------------
  def encounter_list
    return @map.encounter_list
  end
  #--------------------------------------------------------------------------
  # ● エンカウント歩数の取得
  #--------------------------------------------------------------------------
  def encounter_step
    return @map.encounter_step
  end
  #--------------------------------------------------------------------------
  # ● マップデータの取得
  #--------------------------------------------------------------------------
  def data
    return @map.data
  end
  #--------------------------------------------------------------------------
  # ● BGM / BGS 自動切り替え
  #--------------------------------------------------------------------------
  def autoplay
    if @map.autoplay_bgm
      $game_system.bgm_play(@map.bgm)
    end
    if @map.autoplay_bgs
      $game_system.bgs_play(@map.bgs)
    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    # マップ ID が有効なら
    if @map_id > 0
      # すべてのマップイベントをリフレッシュ
      for event in @events.values
        event.refresh
      end
      # すべてのコモンイベントをリフレッシュ
      for common_event in @common_events.values
        common_event.refresh
      end
    end
    # リフレッシュ要求フラグをクリア
    @need_refresh = false
  end
  #--------------------------------------------------------------------------
  # ● 下にスクロール
  #     distance : スクロールする距離
  #--------------------------------------------------------------------------
  def scroll_down(distance)
    @display_y = [@display_y + distance, (self.height - 15) * 128].min
  end
  #--------------------------------------------------------------------------
  # ● 左にスクロール
  #     distance : スクロールする距離
  #--------------------------------------------------------------------------
  def scroll_left(distance)
    @display_x = [@display_x - distance, 0].max
  end
  #--------------------------------------------------------------------------
  # ● 右にスクロール
  #     distance : スクロールする距離
  #--------------------------------------------------------------------------
  def scroll_right(distance)
    @display_x = [@display_x + distance, (self.width - 20) * 128].min
  end
  #--------------------------------------------------------------------------
  # ● 上にスクロール
  #     distance : スクロールする距離
  #--------------------------------------------------------------------------
  def scroll_up(distance)
    @display_y = [@display_y - distance, 0].max
  end
  #--------------------------------------------------------------------------
  # ● 有効座標判定
  #     x          : X 座標
  #     y          : Y 座標
  #--------------------------------------------------------------------------
  def valid?(x, y)
    return (x >= 0 and x < width and y >= 0 and y < height)
  end
  #--------------------------------------------------------------------------
  # ● 通行可能判定
  #     x          : X 座標
  #     y          : Y 座標
  #     d          : 方向 (0,2,4,6,8,10)
  #                  ※ 0,10 = 全方向通行不可の場合を判定 (ジャンプなど)
  #     self_event : 自分 (イベントが通行判定をする場合)
  #--------------------------------------------------------------------------
  def passable?(x, y, d, self_event = nil)
    # 与えられた座標がマップ外の場合
    unless valid?(x, y)
      # 通行不可
      return false
    end
    # 方向 (0,2,4,6,8,10) から 障害物ビット (0,1,2,4,8,0) に変換
    bit = (1 << (d / 2 - 1)) & 0x0f
    # すべてのイベントでループ
    for event in events.values
      # 自分以外のタイルと座標が一致した場合
      if event.tile_id >= 0 and event != self_event and
         event.x == x and event.y == y and not event.through
        # 障害物ビットがセットされている場合
        if @passages[event.tile_id] & bit != 0
          # 通行不可
          return false
        # 全方向の障害物ビットがセットされている場合
        elsif @passages[event.tile_id] & 0x0f == 0x0f
          # 通行不可
          return false
        # それ以外で プライオリティが 0 の場合
        elsif @priorities[event.tile_id] == 0
          # 通行可
          return true
        end
      end
    end
    # レイヤーの上から順に調べるループ
    for i in [2, 1, 0]
      # タイル ID を取得
      tile_id = data[x, y, i]
      # タイル ID 取得失敗
      if tile_id == nil
        # 通行不可
        return false
      # 障害物ビットがセットされている場合
      elsif @passages[tile_id] & bit != 0
        # 通行不可
        return false
      # 全方向の障害物ビットがセットされている場合
      elsif @passages[tile_id] & 0x0f == 0x0f
        # 通行不可
        return false
      # それ以外で プライオリティが 0 の場合
      elsif @priorities[tile_id] == 0
        # 通行可
        return true
      end
    end
    # 通行可
    return true
  end
  #--------------------------------------------------------------------------
  # ● 茂み判定
  #     x          : X 座標
  #     y          : Y 座標
  #--------------------------------------------------------------------------
  def bush?(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil
          return false
        elsif @passages[tile_id] & 0x40 == 0x40
          return true
        end
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● カウンター判定
  #     x          : X 座標
  #     y          : Y 座標
  #--------------------------------------------------------------------------
  def counter?(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil
          return false
        elsif @passages[tile_id] & 0x80 == 0x80
          return true
        end
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 地形タグの取得
  #     x          : X 座標
  #     y          : Y 座標
  #--------------------------------------------------------------------------
  def terrain_tag(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil
          return 0
        elsif @terrain_tags[tile_id] > 0
          return @terrain_tags[tile_id]
        end
      end
    end
    return 0
  end
  #--------------------------------------------------------------------------
  # ● 指定位置のイベント ID 取得
  #     x          : X 座標
  #     y          : Y 座標
  #--------------------------------------------------------------------------
  def check_event(x, y)
    for event in $game_map.events.values
      if event.x == x and event.y == y
        return event.id
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● スクロールの開始
  #     direction : スクロールする方向
  #     distance  : スクロールする距離
  #     speed     : スクロールする速度
  #--------------------------------------------------------------------------
  def start_scroll(direction, distance, speed)
    @scroll_direction = direction
    @scroll_rest = distance * 128
    @scroll_speed = speed
  end
  #--------------------------------------------------------------------------
  # ● スクロール中判定
  #--------------------------------------------------------------------------
  def scrolling?
    return @scroll_rest > 0
  end
  #--------------------------------------------------------------------------
  # ● フォグの色調変更の開始
  #     tone     : 色調
  #     duration : 時間
  #--------------------------------------------------------------------------
  def start_fog_tone_change(tone, duration)
    @fog_tone_target = tone.clone
    @fog_tone_duration = duration
    if @fog_tone_duration == 0
      @fog_tone = @fog_tone_target.clone
    end
  end
  #--------------------------------------------------------------------------
  # ● フォグの不透明度変更の開始
  #     opacity  : 不透明度
  #     duration : 時間
  #--------------------------------------------------------------------------
  def start_fog_opacity_change(opacity, duration)
    @fog_opacity_target = opacity * 1.0
    @fog_opacity_duration = duration
    if @fog_opacity_duration == 0
      @fog_opacity = @fog_opacity_target
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # 必要ならマップをリフレッシュ
    if $game_map.need_refresh
      refresh
    end
    # スクロール中の場合
    if @scroll_rest > 0
      # スクロール速度からマップ座標系での距離に変換
      distance = 2 ** @scroll_speed
      # スクロールを実行
      case @scroll_direction
      when 2  # 下
        scroll_down(distance)
      when 4  # 左
        scroll_left(distance)
      when 6  # 右
        scroll_right(distance)
      when 8  # 上
        scroll_up(distance)
      end
      # スクロールした距離を減算
      @scroll_rest -= distance
    end
    # マップイベントを更新
    for event in @events.values
      event.update
    end
    # コモンイベントを更新
    for common_event in @common_events.values
      common_event.update
    end
    # フォグのスクロール処理
    @fog_ox -= @fog_sx / 8.0
    @fog_oy -= @fog_sy / 8.0
    # フォグの色調変更処理
    if @fog_tone_duration >= 1
      d = @fog_tone_duration
      target = @fog_tone_target
      @fog_tone.red = (@fog_tone.red * (d - 1) + target.red) / d
      @fog_tone.green = (@fog_tone.green * (d - 1) + target.green) / d
      @fog_tone.blue = (@fog_tone.blue * (d - 1) + target.blue) / d
      @fog_tone.gray = (@fog_tone.gray * (d - 1) + target.gray) / d
      @fog_tone_duration -= 1
    end
    # フォグの不透明度変更処理
    if @fog_opacity_duration >= 1
      d = @fog_opacity_duration
      @fog_opacity = (@fog_opacity * (d - 1) + @fog_opacity_target) / d
      @fog_opacity_duration -= 1
    end
  end
end
