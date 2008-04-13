cd /var/www/rails/greenchange
ls
git status
mongrel_rails restart
git status
vim app/models/page
vim app/models/page.rb 
git status
git commit -a -m "permissions and url fixes for zheng"
git push
su greenchange
exit
tail -f log/development.log 
tail -f log/development.log  | grep ###
tail -f log/development.log  | grep \#\#\#
exit
script/console
git status
git add app/views/shared/sides/
git add app/views/shared/_contacts.html.haml 
git add app/views/shared/_groups.html.haml 
git add app/views/shared/_issues.html.haml 
git add app/views/me/sides/
git status
git add app/views/pages/new.html.erb 
exit
cd /home/greenchange/greenchange
su greenchange
rm -rf vendor/plugins/fleximage/
vim .gitmodules
rm .gitmodules
vim .git/config 
git status
git commit -a -m 'remove all traces of fleximage'
chown -R greenchange *
su greenchange
chown -R www-data assets
chown -R www-data log/*
chown -R www-data public/images/uploaded
mkdir public/images/uploaded
chown -R www-data public/images/uploaded
chown -R tmp
chown -R www-data tmp
vim spec/models/asset_spec.rb 
rake spec
screen -x
screen -x 28
screen -x 
mongrel_rails stop
mongrel_rails start -p 3400
mongrel_rails start -p 3400 -d
exit
lcoate stagging.radicaldesigns.org
locate stagging.radicaldesigns.org
locate staging
locate staging.rad
vi /etc/apache2/sites-available/staging.radicaldesigns.org 
vi /etc/apache2/sites-available/staging.radicaldesigns.org 
cd /home/greenchange/greenchange
vim app/helpers/context_helper.rb 
exit
cd /home/greenchange/greenchange
script/console
rake db:seed
script/console
exit
cd /var/www/rails/greenchange
ls
git status
mongrel_rails restart
mongrel_rails start -d -p 3030
mongrel_rails stop
vi config/
vi config/environment.rb 
mongrel_rails start -d -p 3040
git s
vi app/views/tool/blog/show.
vi app/views/tool/blog/show.html.haml 
rake spec
mongrel_rails start -d -p 3400
mongrel_rails stop
mongrel_rails start -d -p 3400
mongrel_rails start -d -p 3040
mongrel_rails stop
mongrel_rails start -d -p 3040
cd app/views/
vi groups/new.html.haml 
cd ../../public/images/gc/icons/pages/large/
wget http://www.greenchange.org/img/thumb/icon_group.jpg
mv icon_group.jpg group.jpg
cd ../../../
cd ../../
cd ../app/views/
vi groups/new.html.haml 
cd ../../public/images/gc/icons/pages/
ls
cd large/
ls
cd ../../../../../
cd ../app/views/
vi groups/new.html.haml 
vi account/signup.haml 
vi account/login.haml 
vi account/index.rhtml 
vi account/index.haml 
vi pages/list/_page.html.haml 
vi groups/_menu.html.haml 
vi groups/_menu.html.haml 
cd /var/www/rails/greenchange
cd app/views/
vi groups/_info.html.haml 
vi groups/show.haml 
vi profile/_form.rhtml 
vi me/profiles/_form.html.haml 
vi profile/_form.rhtml 
vi me/profiles/_form.html.haml 
git checkout people/profiles/show.html.haml 
vi people/profiles/show.html.haml 
vi people/profiles/show.html.haml 
cd /var/www/rails/greenchange
ls
cd app/views/
vi ../../public/stylesheets/sass/ui.sass 
vi pages/_form_metadata.html.haml 
vi ../../public/stylesheets/sass/ui.sass 
vi ../../public/stylesheets/sass/forms.sass 
vi ../../public/stylesheets/sass/forms.sass 
vi tool/action_alert/_form.html.haml 
vi tool/news/_form.html.haml 
vi tool/discussion/_form.html.haml 
vi pages/_form_metadata.html.haml 
vi new tool/blog
vi new tool/blog/_form.html.haml
vi pages/_form_metadata.html.haml 
cd ../../
git status
exit
cd /var/www/rails/greenchange
git status
cd app/views/
vi groups/_info.html.haml 
