require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'digest/md5'
require 'zipruby'

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
      Dir.chdir("/home/yuiseki/workspace/arakawa-generate-jacket/generator/")
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
      <h1 style="font-size:4em;margin-top:2px;padding-top:2px;">
      arakawa-generate-jacket
      </h1>
      <p> by 荒川智則 works. </p>
      <a href="/link/<%= @seed %>">
        your jacket is here!
        <br/>
        <img src="/jacket.png" alt="your jacket is here!" title="your jacket is here!" />
      </a>
      <hr />
        Recent jackets log:
        <br/>
        <div class="jackets">
      <% @files.each do |file| %>
          <a href="/link/<%= file.split('.').first %>">
            <img src="/jacket/<%= file %>" />
          </a>
      <% end %>
        </div>
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
  # TODO request元のホスト名がわかったらそれを文字列として渡すように変更
  seed = make_seed(request.env["REMOTE_ADDR"])
  path = get_or_create(seed)
  # TODO キャッシュを無効にする
  # TODO Content-typeを適切に設定
  send_file path
end


# zipの動的生成のためのエンドポイント
get '/MARU.zip' do
  seed = make_seed(request.env["REMOTE_ADDR"])
  jpath = jacketpath(seed)

  dirpath = '/home/yuiseki/workspace/arakawa-generate-jacket/sinatra/public/maru76'
  files = []
  Dir::foreach(dirpath) {|f|
    next if f == "." or f == ".." or f == ".gitignore" or f == "maru76.zip"
    files.push dirpath + "/" + f
  }
  files.push jpath
  file_buffers = Hash.new
  files.each do |path|
    # fileをbufferにためる
    filename = File::basename(path)
    file = open(path, "rb")
    file_buffers.store filename, file.read
    file.close
    # ファイルを閉じる
  end

  # オンメモリでzipファイルを生成
  zip_buffer = ''
  Zip::Archive.open_buffer(zip_buffer, Zip::CREATE, Zip::NO_COMPRESSION) do |zipb|
    # fileのbufferをzipのbufferにつっこんでいく
    file_buffers.each_pair do |filename, buf|
      zipb.add_buffer(filename, buf)
    end
  end

  # メモリ上のデータを送信
  content_type 'application/zip'
  attachment 'MARU.zip'
  zip_buffer

end








