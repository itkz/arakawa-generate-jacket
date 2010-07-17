require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'digest/md5'

template :layout do
<<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title><%= @title %></title>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
EOF
end


helpers do
  def make_seed(ipaddr)
    # MD5 hashを計算
    str = ipaddr.to_s
    hash = Digest::MD5.new.update(str)
    return hash
  end

  def jacketpath(seed)
    return "/home/yuiseki/workspace/arakawa-generate-jacket/sinatra/public/jacket/#{seed}.png"
  end

  def create_jacket(seed, path)
    # seedをもとに画像を生成してpngにして既定のパスに保存
    flag = true
    begin
      Dir.chdir("/home/yuiseki/workspace/arakawa-generate-jacket/")
      system("./arakawajacket #{seed} /tmp/#{seed}.bmp")
      system("convert /tmp/#{seed}.bmp #{path}")
    rescue
      flag = false
    end
    return flag
  end

  def get_or_create(seed)
    # ファイルがすでにないか確認する
    path = jacketpath(seed)
    unless File.exist?(path)
      # なければ画像生成コマンドを実行
      create_jacket(seed, path)
    end
    return path
  end
end


# トップページ
get '/' do
  @seed = make_seed(request.env["REMOTE_ADDR"])

  # TODO public/jacketフォルダを時刻順で並べ替えて出力
    @files = []
    Dir::foreach('/home/yuiseki/workspace/arakawa-generate-jacket/sinatra/public/jacket') {|f|
      next if f == "." or f == ".." or f == ".gitignore"
      @files.push f
    }

  # TODO cookieから自分が生成した画像へのリンクを出したい
  erb %{
    <div class="main">
      <h1 style="font-size:5em;">
      arakawa-generate-jacket
      </h1>
      <a href="/link/<%= @seed %>">
        your jacket is here!
      </a>
      <% @files.each do |file| %>
        <div class="link">
          <a href="/link/<%= @seed %>">
            <img src="/jacket/<%= file %>" />
          </a>
        </div>
      <% end %>
  </div>
  }
end



# seedから生成されたジャケットの画像取得はpassengerがpublic/以下を自動でルーティング
# 生成されたジャケットの個別ページparmalink seedをIDにつかう
get '/link/:seed_string' do |st|
  # TODO twitterに投稿するボタンでもつける
  @seed = st
  erb %{
    <h1 style="font-size:5em;">
      <img src="/jacket/<%= @seed %>.png">
    </h1>
  }
end




# ジャケット自動生成のためのエンドポイント
get '/jacket.png' do
  # TODO seedと日時をcookieに記録しておく
  # TODO キャッシュを無効にする
  # TODO request元のホスト名がわかったらそれを文字列として渡すように変更
  seed = make_seed(request.env["REMOTE_ADDR"])
  path = get_or_create(seed)
  # 画像をレスポンスする
  send_file path
end








