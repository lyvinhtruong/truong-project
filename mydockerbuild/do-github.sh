cd /var/www/html/

echo "Cloning your project..."

repo=$1
branch=$2

if [[ -z "$branch"  ]]; then
    echo "No branch name was inputted, 'master' branch will be checked out"
    git clone $repo .
else
    git clone -b $branch $repo .
fi

res_clone=$?
echo "Status code: $res_clone"

if [[ $res_clone -ne 0 ]]; then
    echo "Cannot clone source code but you can still do this manually after creating machine."
fi

