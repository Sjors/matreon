# Matreon Release process

`Status: work in progress`

## Steps

### Tag Release

- [ ] git tag

### Update AWS Template

- [ ] download the tagged [Matreon.Template](https://raw.githubusercontent.com/Sjors/matreon/master/vendor/AWS/Matreon.Template)
- [ ] remove `Developer` section (from `ParameterGroups`)
- [ ] upload to S3 bucket (https://s3.eu-central-1.amazonaws.com/matreon/Matreon.Template) 
