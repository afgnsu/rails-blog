這是一個具有基本功能部落格的建置：

1. 搭建後台(gem activeadmin)
2. 使用產生Post CRUD (文章 創建/讀取/更新/刪除)(rails generate scaffold)
3. 文章貼照片(gem carrierwave )
4. 加裝WYSIWYG文字編輯器(gem ckeditor)
5. 可加tag (使用gem acts_as_taggable-on，類似概念也可應用在增加類別)
6. 可嵌入程式碼(ckeditor code snippet plugin / highlight.js)

## 創建專案
使用postgresql做數據庫，另外我使用webpack。
```
rails new blog --database=postgresql --webpack
```
## 使用activeadmin搭建後台
```
gem 'activeadmin'
gem 'devise'
```
我們需要activeadmin和devise這兩個gem
```
bundle install
rails g active_admin:install
rails db:create
rails db:migrate
rails db:seed
rails server
```

確認一下seed.rb，預設在development環境使用者名稱和密碼為：
User: admin@example.com
Password: password

## 文章Post CRUD
這裡使用rails g scaffold指令快速生成部落格文章CRUD，並讓activeadmin和Post產生關聯。
首先，你需先改一下組態，避免此問題：
https://github.com/activeadmin/inherited_resources/issues/195

```
# config/application.rb
module SampleApp
  class Application < Rails::Application
    ...
    config.app_generators.scaffold_controller = :scaffold_controller
    ...
  end
end
```
```
rails g scaffold post title body:text
rails generate active_admin:resource Post
```
這時你直接從後台建立post會發生錯誤，是因為strong params的問題，需做以下修正：
```
# app/admin/posts.rb

ActiveAdmin.register Post do
    permit_params :title, :body
end
```
## 加入WYSIWYG文字編輯器: ckeditor
```
# config/initializers/assets.rb
Rails.application.config.assets.precompile += %w( ckeditor/*)
```
```
rails generate ckeditor:install --orm=active_record --backend=carrierwave
```
```
rails db:migrate
mkdir app/assets/javascripts/ckeditor
touch app/assets/javascripts/ckeditor/config.js
```

參考用組態
```
# app/assets/javascripts/ckeditor/config.js
CKEDITOR.editorConfig = function( config ) {
config.language = 'en';
config.uiColor = '#ffffff';
/* Filebrowser routes */
// The location of an external file browser, that should be launched when "Browse Server" button is pressed.
config.filebrowserBrowseUrl = "/ckeditor/attachment_files";
// The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Flash dialog.
config.filebrowserFlashBrowseUrl = "/ckeditor/attachment_files";
// The location of a script that handles file uploads in the Flash dialog.
config.filebrowserFlashUploadUrl = "/ckeditor/attachment_files";
// The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Link tab of Image dialog.
config.filebrowserImageBrowseLinkUrl = "/ckeditor/pictures";
// The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Image dialog.
config.filebrowserImageBrowseUrl = "/ckeditor/pictures";
// The location of a script that handles file uploads in the Image dialog.
config.filebrowserImageUploadUrl = "/ckeditor/pictures?";
// The location of a script that handles file uploads.
config.filebrowserUploadUrl = "/ckeditor/attachment_files";
config.allowedContent = true;
// Toolbar groups configuration.
config.toolbar = [
{ name: 'document', groups: [ 'mode', 'document', 'doctools' ], items: [ 'Source'] },
{ name: 'clipboard', groups: [ 'clipboard', 'undo' ], items: [ 'Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo' ] },
// { name: 'editing', groups: [ 'find', 'selection', 'spellchecker' ], items: [ 'Find', 'Replace', '-', 'SelectAll', '-', 'Scayt' ] },
// { name: 'forms', items: [ 'Form', 'Checkbox', 'Radio', 'TextField', 'Textarea', 'Select', 'Button', 'ImageButton', 'HiddenField' ] },
{ name: 'links', items: [ 'Link', 'Unlink', 'Anchor' ] },
{ name: 'insert', items: [ 'Image', 'Flash', 'Table', 'HorizontalRule', 'SpecialChar' ] },
{ name: 'paragraph', groups: [ 'list', 'indent', 'blocks', 'align', 'bidi' ], items: [ 'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'Blockquote', 'CreateDiv', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock' ] },
'/',
{ name: 'styles', items: [ 'Styles', 'Format', 'Font', 'FontSize' ] },
{ name: 'colors', items: [ 'TextColor', 'BGColor' ] },
{ name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ], items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ] },
];
config.toolbar_mini = [
{ name: 'paragraph', groups: [ 'list', 'indent', 'blocks', 'align', 'bidi' ], items: [ 'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'Blockquote', 'CreateDiv', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock' ] },
{ name: 'styles', items: [ 'Font', 'FontSize' ] },
{ name: 'colors', items: [ 'TextColor', 'BGColor' ] },
{ name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ], items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ] },
{ name: 'insert', items: [ 'Image', 'Table', 'HorizontalRule', 'SpecialChar' ] },
];
// alert(CKEDITOR.version); //TO FIND OUT VERSION, REMOVE ONCE NO LONGER REQUIRED
};
```

到application.js，加上//= require ckeditor/init ，必須放在//= require_tree .之前
//= require ckeditor/init
```
# need before...

//= require_tree .
```
然後還需要以下配置：
```
# in config/initializers/assets.rb

Rails.application.config.cdn_url = '//cdn.ckeditor.com/4.11.1/standard/ckeditor.js'
# /config/initializers/active_admin.rb
config.register_javascript 'ckeditor/init.js'


# app/admin/posts.rb

form do |f|
    f.inputs do
      f.input :title
      f.input :body, :as => :ckeditor
    end
    f.actions
end
```

會需要修改一下樣式，來讓文字編輯器和表格更fit
```
# app/assets/stylesheets/active_admin.scss
.cke_chrome {
  width: 79.5% !important;
  overflow: hidden;
}
```

可能會發現，你編輯好文章提交後，頁面顯示的是純html碼而不是純文字圖片。這是你需要做些修改：
例如，在view的部分
```
<p>
  <strong>Body:</strong>
  <%= @post.body.html_safe %>
</p>
```
而在admin裡面，就看你想要怎麼來客製化裡面的column和row，你可能會用到：
```
# app/admin/posts.rb
index do
    # ...
    column (:body) { |post| raw(post.body) }
    # ...
end

show do
    # ...
    row (:body) { |post| raw(post.body) }
    # ...
end
```
我想你會需要參考:
https://activeadmin.info/3-index-pages/index-as-table.html

## ActsAsTaggableOn
```
gem 'acts-as-taggable-on'
```
```
bundle install
rake acts_as_taggable_on_engine:install:migrations
rake db:migrate
```
修改model和controller
```
# post.rb 

class Post < ApplicationRecord
    acts_as_taggable
end
# posts_controller.rb

class PostsController < InheritedResources::Base

  private

    def post_params
      params.require(:post).permit(:title, :body, :tag_list)
    end
end
```
```
# app/admin/posts.rb
ActiveAdmin.register Post do
    permit_params :title, :body, :tag_ids => []

    before_create do |post|
        post.tag_list = params["post"]["tag_list"]
    end

    before_update do |post|     
        post.tag_list = params["post"]["tag_list"]
    end

    form do |f|
        f.inputs do
          f.input :title
          f.input :body, :as => :ckeditor
          f.input :tag_list, :input_html => {:value => f.object.tag_list.join(", ") }, :label => "Tags (separated by commas)".html_safe
        end
        f.actions
    end    
end
```

## 嵌入程式碼 code snippet
```
// app/assets/javascripts/ckeditor/config.js

CKEDITOR.editorConfig = function( config ) {
    config.extraPlugins = 'codesnippet';
    
    //...
    
    config.toolbar = [
    
        //...
        
        { name: 'document', groups: [ 'mode', 'document', 'doctools' ], items: [ 'CodeSnippet'] }
        
        //...
   ];
};
```
下載Code Snippet plugin，記得下載符合 CKEditor 版本的。下載完成解壓縮後放置到
app/assets/javascripts/ckeditor/plugins
接著你需要安裝 Highlight.js，到這個網址下載後解壓縮，把highlight.pack.js檔案放置到app/assets/javascripts
挑選一個喜歡的style.css檔案，複製到app/assets/stylesheets，可以在這裡預覽效果

在javascript加入hljs.initHighlightingOnLoad()來生成效果，但我的網頁在render的時候有點問題，會導致每次都要手動按重新整理才會出現code snippet的樣式，後來改成以下方案。
```
// hljs.initHighlightingOnLoad(); //可以先試試只加這行
hljs.initHighlighting.called = false;
hljs.initHighlighting();
```

## Troubleshooting
此外，我有遇到以下問題，如果同樣需要的人，請參考：
* CKEditor 4: Uncaught TypeError: Cannot read property 'langEntries' of null:
https://medium.com/r/?url=https%3A%2F%2Fstackoverflow.com%2Fquestions%2F24500525%2Fckeditor-4-uncaught-typeerror-cannot-read-property-langentries-of-null

* ActiveAdmin styles are applied on non-ActiveAdmin pages:
https://medium.com/r/?url=https%3A%2F%2Fgithub.com%2Factiveadmin%2Factiveadmin%2Fissues%2F3819
