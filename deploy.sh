USER=yaskevich
APP=flowercat
BRANCH=master
PROD=production
DIR=$(pwd)
WORK=$DIR/$PROD/$APP
UUID=$(cat /proc/sys/kernel/random/uuid)
TEMP=$DIR/$APP-$UUID

mkdir $TEMP -p

mv $WORK/backup/ $TEMP
mv $WORK/images/ $TEMP
mv $WORK/sites/ $TEMP


pm2 delete $APP
rm -rf $DIR/$PROD/$APP
# degit $USER/$APP#$BRANCH $WORK
git clone https://github.com/$USER/$APP $WORK --depth 1
HASH=$(git -C $WORK rev-parse --short HEAD)
# echo $HASH

rm $WORK/* 2>/dev/null
rm $WORK/.* 2>/dev/null
npm install --prefix $WORK/client
npm run build --prefix $WORK/client
mv $WORK/client/dist $WORK/public

cd $WORK/server
for i in *
do
  if [ -f "$i" ]; then
    mv "$i" $WORK
  fi
done

npm install --prefix $WORK
cp $DIR/$APP.env $WORK/.env
printf "\nCOMMIT=%s" $HASH >> $WORK/.env

mv $TEMP/backup $WORK
mv $TEMP/images $WORK
mv $TEMP/sites $WORK

rm -rf $TEMP

cd $WORK
rm -rf $WORK/client $WORK/server
# # https://pm2.keymetrics.io/docs/usage/application-declaration/#ecosystem-file
# # --cwd
pm2 start ecosystem.config.cjs --cwd $WORK
pm2 save
