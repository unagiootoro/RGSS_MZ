#==============================================================================
# ■ Scene_Status
#------------------------------------------------------------------------------
# 　ステータス画面の処理を行うクラスです。
#==============================================================================

class Scene_Status
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     actor_index : アクターインデックス
  #--------------------------------------------------------------------------
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
  end
  #--------------------------------------------------------------------------
  # ● メイン処理
  #--------------------------------------------------------------------------
  def main
    # アクターを取得
    @actor = $game_party.actors[@actor_index]
    # ステータスウィンドウを作成
    @status_window = Window_Status.new(@actor)
    # トランジション実行
    Graphics.transition
    # メインループ
    loop do
      # ゲーム画面を更新
      Graphics.update
      # 入力情報を更新
      Input.update
      # フレーム更新
      update
      # 画面が切り替わったらループを中断
      if $scene != self
        break
      end
    end
    # トランジション準備
    Graphics.freeze
    # ウィンドウを解放
    @status_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # B ボタンが押された場合
    if Input.trigger?(Input::B)
      # キャンセル SE を演奏
      $game_system.se_play($data_system.cancel_se)
      # メニュー画面に切り替え
      $scene = Scene_Menu.new(3)
      return
    end
    # R ボタンが押された場合
    if Input.trigger?(Input::R)
      # カーソル SE を演奏
      $game_system.se_play($data_system.cursor_se)
      # 次のアクターへ
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      # 別のステータス画面に切り替え
      $scene = Scene_Status.new(@actor_index)
      return
    end
    # L ボタンが押された場合
    if Input.trigger?(Input::L)
      # カーソル SE を演奏
      $game_system.se_play($data_system.cursor_se)
      # 前のアクターへ
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      # 別のステータス画面に切り替え
      $scene = Scene_Status.new(@actor_index)
      return
    end
  end
end
