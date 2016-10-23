#  safari.digital App

## Colors

* Back / Cancel:
```
[UIColor colorWithRed:0.09 green:0.10 blue:0.12 alpha:1.00]
UIColor(red:0.09, green:0.10, blue:0.12, alpha:1.00)
```

## Images

### Sizes

* Small: 375x300

## git

Check all the entries in the index which references a submodule
```
git ls-files --stage | grep 160000
```

Cloning git project and init submodules 
```
git clone git://github.com/schacon/myproject.git
git submodule init
git submodule update
```
