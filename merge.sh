branch=`git symbolic-ref --short -q HEAD`
echo "current branch:$branch"
git checkout dev
git pull origin dev

git pull origin $branch
git merge $branch
git push origin dev
git checkout $branch
sleep 10
