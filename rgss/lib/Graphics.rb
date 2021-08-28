=begin
Graphics
グラフィック全体にかかわる処理を行うモジュール。

モジュールメソッドGraphics.update 
ゲーム画面を更新し、時間を 1 フレーム進めます。このメソッドは必ず定期的に呼び出す必要があります。

loop do
  Graphics.update
  Input.update
  do_something
end

このメソッドが 10 秒以上に渡って実行されなかった場合、スクリプトが暴走したとみなして強制終了されます。

Graphics.freeze 
トランジションの準備として、現在の画面を固定します。

これ以後 transition メソッドを呼び出すまでは、一切の画面の書き換えが禁止されます。

Graphics.transition([duration[, filename[, vague]]]) 
freeze メソッドで固定した画面から現在の画面へのトランジションを行います。

duration はトランジションにかけるフレーム数です。省略時は 8 になります。

filename はトランジション グラフィックのファイル名を指定します (指定しない場合は通常のフェードになります) 。RGSS-RTP、暗号化アーカイブに含まれるファイルも自動的に探します。拡張子は省略可能です。

vague は転送元と転送先の境界のあいまいさで、値が大きいほどあいまいになります。省略時は 40 になります。

Graphics.frame_reset 
画面の更新タイミングをリセットします。時間のかかる処理の後にこのメソッドを呼ぶことで、極端なフレームスキップが発生しないようにすることができます。

モジュールプロパティGraphics.frame_rate 
[滑らかモード] のときに 1 秒間に画面を更新する回数です。値が大きいほど多くの CPU パワーが必要になります。通常は 40 です。[滑らかモード] でない場合、更新回数は半分になり、1 フレームごとにスキップして描画されます。

このプロパティを変更することは推奨されませんが、変更する場合は 10 ～ 120 の範囲で指定します。範囲外の値は自動で修正されます。

Graphics.frame_count 
画面の更新回数のカウントです。ゲーム開始時にこのプロパティを 0 に設定しておくと、frame_rate プロパティの値で割ることで、ゲームのプレイ時間 (秒数) が算出できます。

=end

module Graphics
  class << self
    attr_accessor :frame_rate
    attr_accessor :frame_count

    def _init
      @frame_rate = 60
      @frame_count = 0
      @sprites = []
    end

    def _add_sprite(sprite)
      @sprites.push(sprite)
    end

    def _remove_sprite(sprite)
      @sprites.delete(sprite)
    end

    def update
      @sprites.each do |sprite|
        sprite._update_by_system
      end
      loop_count = 0
      while true
        break if RGSSEnv.check_graphics_updated
        loop_count += 1
        raise "endless loop error." if loop_count > 1000
        Fiber.yield
      end
      @frame_count += 1
      Fiber.yield
    end

    def freeze

    end

    def transition(duration = nil, filename = nil, vague = nil)

    end

    def frame_reset

    end
  end
end

Graphics._init
