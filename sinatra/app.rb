
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'digest/md5'
require 'zipruby'
require 'id3lib'
require 'fileutils'
require 'kconv'

template :layout do
<<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title><%= @title %></title>
    <%= @head %>
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

  def zippath(seed)
    return "/home/yuiseki/workspace/arakawa-generate-jacket/sinatra/tmp/#{seed}.zip"
  end
  def dirpath(seed)
    return "/home/yuiseki/workspace/arakawa-generate-jacket/sinatra/tmp/mp3_#{seed}/"
  end
  def randpath
    puts "called randpath"
    # tmpdirが空＝初回のzip生成のときはpublic/maru76から複製する
    tmpdir = "/home/yuiseki/workspace/arakawa-generate-jacket/sinatra/tmp/"
    srcdir = ""

    unless File.exist?("/home/yuiseki/workspace/arakawa-generate-jacket/sinatra/public/maru76/lock")
      # オリジナルがロックされてなければそれを使えばおｋ
      srcdir = "/home/yuiseki/workspace/arakawa-generate-jacket/sinatra/public/maru76/"
    else
      puts "----start tmpdir search"
      # ID3tagを書き換えるために他のスレッドとかぶらないように複製元を選ぶ
      Dir::foreach(tmpdir) {|f|
        # ディレクトリのみしらべる
        next unless File::ftype(f) == "directory"
        next if f == "." or f == ".."
        # ロックされていないディレクトリを発見したら
        puts "checking #{tmpdir+f} ..."
        unless File.exist?(tmpdir+f+"/lock")
          # ファイルがすべてちゃんとあるか調べる
          if Dir.entries(tmpdir+f).size == 10
            srcdir = tmpdir+f
            break
          end
        end
      }
    end
    puts srcdir
    return srcdir
  end
  def create_zip(seed)
    puts "called create_zip"
    jpath = get_or_create(seed)
    zpath = zippath(seed)
    dpath = dirpath(seed)
    puts "#{jpath}\n#{zpath}\n#{dpath}"

    # dpathにディレクトリをつくる
    Dir::mkdir(dpath) unless File.exist?(dpath)
    # dpathに開始をマークする
    File.open(dpath+"started", "w").close()

    # mp3をコピーするディレクトリをランダムに選ぶ
    mp3dir = randpath
    puts "copy sorce is #{mp3dir}"
    # 複製開始前にロックをマーク
    File.open(mp3dir+"lock", "w").close()
    File.open(dpath+"lock", "w").close()
    # mp3dirからdpathへ全ファイルを複製
    Dir::foreach(mp3dir) {|f|
      next if f == "." or f == ".." or f == ".gitignore" or f == "maru76.zip" or f == "lock"
      src = mp3dir + f
      puts "copy #{f}"
      FileUtils.copy(src, dpath, {:preserve => true}) unless File.exist?(dpath+f)
    }

    # dpathの全ファイルの絶対パスの配列
    files = []
    Dir::foreach(dpath) {|f|
      next if f == "." or f == ".." or f == ".gitignore" or f == "maru76.zip"
      files.push dpath + f
    }
    # dpathの全mp3ファイル書き換え
    files.each do |path|
      puts "edit #{path}"
      tag = ID3Lib::Tag.new(path)
      cover = {
        :id          => :APIC,
        :mimetype    => 'image/png',
        :picturetype => 3,
        #:description => 'Arakawa Tomonori',
        #:textenc     => 0,
        :data        => File.read(jpath)
      }
      tag << cover
      tag.update!
    end

    # ジャケット画像を追加
    files.push jpath

    # dpathの全ファイルから無圧縮zipファイル生成、zpathに書き出し
    Zip::Archive.open(zpath, Zip::CREATE, Zip::NO_COMPRESSION) do |zip|
      puts "make zip"
      files.each do|path|
        next if path == dpath+"started" or path == dpath+"ziped" or path == dpath+"lock"
        puts path
        zip.add_file(path)
      end
    end

    # zip生成が完了したディレクトリのロックを解除
    File.delete(mp3dir+"lock")
    File.delete(dpath+"lock")
    # zip完了をマーク
    File.open(dpath+"ziped", "w").close()
  end


end











# トップページ
get '/' do
  @seed = make_seed(request.env["REMOTE_ADDR"])

  # public/jacketフォルダを時刻順で並べ替えて出力
  @files = Dir.glob("/home/yuiseki/workspace/arakawa-generate-jacket/sinatra/public/jacket/*").sort_by {|f| File.mtime(f)}.reverse

  # TODO cookieから自分が生成した画像へのリンクを出したい
        #&status=http%3A%2F%2Fmimimi.xn--fdr45z90g374a.jp%2Flink%2F<%= @seed %>+%23maru76">
  erb %{
    <div class="main">
      <h1 style="font-size:4em;margin-top:2px;padding-top:2px;">
      arakawa-generate-jacket
      </h1>
      <p> by 荒川智則 works. </p>
      <a href="http://twitter.com/home/?source=mimimi
        &status=http%3A%2F%2Fmimimi.荒川智則.jp%2Flink%2F<%= @seed %>+%23maru76">
        <img src="http://twitter.com/favicon.ico" />tweet your jacket!</a>
      <br />
      <a href="/link/<%= @seed %>">
        your jacket is here!
        <br/>
        <img src="/jacket.png" alt="your jacket is here!" title="your jacket is here!" />
      </a>
      <hr />
        Recent jackets log:
        <br/>
        <div class="jackets">
      <% @files.slice!(0,48).each do |file| %>
          <a href="/link/<%= File.basename(file).split('.').first %>">
            <img src="/jacket/<%= File.basename(file) %>" />
          </a>
      <% end %>
        </div>
  </div>
  }
end




# seedから生成されたジャケットの画像取得はpassengerがpublic/以下を自動でルーティング
# 生成されたジャケットの個別ページparmalink seedをIDにつかう
get '/link/:seed_string' do |st|
  @seed = st
  erb %{
    <a href="http://twitter.com/home/?source=mimimi
      &status=http%3A%2F%2Fmimimi.荒川智則.jp%2Flink%2F<%= @seed %>+%23maru76">
      <img src="http://twitter.com/favicon.ico" />tweet this jacket!</a>

    <h1 style="font-size:5em;">
      <img src="/jacket/<%= @seed %>.png">
    </h1>

    <a href="/">check other jackets!!</a><br />
  }
end



# ジャケット自動生成のためのエンドポイント
get '/jacket.png' do
  # TODO seedと日時をcookieに記録しておく
  # TODO request元のホスト名がわかったらそれを文字列として渡すように変更
  seed = make_seed(request.env["REMOTE_ADDR"])
  path = get_or_create(seed)
  # TODO キャッシュを無効にする
  content_type 'image/png'
  send_file path
end

get '/jacket' do
  seed = make_seed(request.env["REMOTE_ADDR"])
  redirect "/link/#{seed}"
end


get '/get_or_create' do
  seed = make_seed(request.env["REMOTE_ADDR"])
  zpath = zippath(seed)
  dpath = dirpath(seed)
  if File.exist?(dpath)
    # ディレクトリが存在している＝生成処理着手済み
    if File.exist?(zpath)
      # zipが存在している＝trueを返す
      "1"
    else
      # 生成処理が完了していないだけなのでなにもしない
      "0"
    end
  else
    # ディレクトリが存在しない＝初回なのでzip生成スレッド実行
    # TODO スレッドの数を数えてやばそうだったら実行抑止する
    begin
      t = Thread.new do
        puts "----create zip thread----"
        create_zip(seed)
      end
    end
    "0"
  end
end







# zipの動的生成のためのエンドポイント
get '/maru76.zip' do
  # IPアドレスをもとに送信するzipを決定
  seed = make_seed(request.env["REMOTE_ADDR"])
  zpath = zippath(seed)
  dpath = dirpath(seed)
  if File.exist?(zpath)
    content_type 'application/zip'
    attachment 'maru76.zip'
    send_file zpath
  else
    unless File.exist?(dpath+"started")
      begin
        t = Thread.new do
          puts "----create zip thread for #{seed}----"
          create_zip(seed)
        end
      end
    end

    #status 503
    #response["Retry-After"] = 120
    @head = '<meta http-equiv="refresh" content="2">'
    erb %{
      zipファイルの生成を開始しました。
      自動でダウンロードを再試行しますので、このまましばらくお待ちください。
      <a href="/maru76.zip">手動で再試行</a>もできます。
     }
  end
end








