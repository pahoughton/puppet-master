#!/usr/bin/env python3.3
'''gitolite post-receive hook

Executed after successful push to the repo to notify, jenkins, trac and/or
mirror the repo.

Usse:
    Add config keys to ~GIT/.gitolite.rc
    GIT_CONFIG_KEYS => 'gitolite\.url jenkins\.url jenkins\.build\.job jenkins\.build\.token trac\.dir trac\.repo git\.mirror\.repo',

    Add values as needed to your gitolite.conf
    repo @all
    
    repo myproduct.git
        config gitolite.url = git@gitolite.host.com
        config jenkins.url = http://host.com/jenkins
        config jenkins.build.job = JENKINS_JOB_NAME%20NOSPACE
        config jenkins.build.token = JENK_JOB_TOKEN
        config git.mirror.repo = git@github:USER/pubprod.git

    Install this script as ~GIT/REPO_DIR/MYPRODUCT.git/hooks/post-receive
    
Both jenkins.build.job and jenkins.build.token are provided by the 
build configuration that will be signaled by the push.    
    
NOTE: the trac-admin app used is either 'trac-admin' or the value of
the TRAC_ADMIN_APP environment variable. This is set to 'echo' for
unit testing.

Trac Tickets: #17, #19, #57, #58
'''
import sys
import os
import urllib.request
import subprocess
import shutil

def show_post_receive_env():
    '''For testing / debugging only
    Show the user that did the push all the values available to the
    post-receive hook    
    Values may be args (none expected), environment variables and
    read from stdin in the formation of: OLDREV NEWREV REFNAME
    '''
    print('ARGLIST:')
    for a in sys.argv:
        print('ARG: '+a)
        
    print('ENVLIST:')
    for k,v in os.environ.items():
        print('ENV: '+k+'='+v)


def git_config(repoVar):
    '''return the value from a git config variable
    
    This is able to retrieve gitolite repo variables when
    the script is a gitolite hook.
    '''
    cfgVal = None
    try:
        cfgVal = subprocess.check_output(['git',
                                          'config',
                                          '--get',
                                          repoVar]
                                         ).decode('utf-8').strip()
    except:
        pass
    
    return cfgVal

def notify_jenkins(jenkinsUrl, branches):
    '''Send notification to jenkinsUrl of the push
    
    '''
    gitoliteUrl = git_config('gitolite.url')
    jenkinsBuildJob = git_config('jenkins.build.job')
    jenkinsBuildToken = git_config('jenkins.build.token')
    

    reqUrl = jenkinsUrl
    if jenkinsBuildJob and jenkinsBuildToken:
        # this url is directly from the jenkins job definition
        reqUrl += '/job/'+jenkinsBuildJob
        reqUrl += '/build?token='+jenkinsBuildToken
        reqUrl += '&cause=Cause+git+push'
    elif gitoliteUrl:
        # this url is from the git jenkins plugin
        # note: GitPython does not work with python3
        reqUrl += '/git/notifyCommit?url=' + gitoliteUrl
        reqUrl += ':' + os.environ.get('GL_REPO')
        if len(branches):
            reqUrl += '&branches='+','.join(branches)
    else:
        reqUrl = None
        
    #print('ReqUrl:',reqUrl)
    if reqUrl:
        try:
            resp = urllib.request.urlopen(reqUrl)
            if resp and resp.status == 200:
                print('Jenkins notified via:',
                      reqUrl,
                      'response was:',
                      resp.read()
                      )
            else:
                print('jenkins request failed: '+reqUrl + str(resp.status))
        except:
            print('Jenkins request failed: '+reqUrl)
            
    else:
        print( 'Repo not configured for continuous integration.' )

    
def main():
    '''app entry

    '''

    # Notify Trac
    trac_dir = git_config('trac.dir')
    trac_repo = git_config('trac.repo')
    
    trac_admin = 'trac-admin'
    if os.environ.get('TRAC_ADMIN_APP'):
        trac_admin = os.environ.get('TRAC_ADMIN_APP')
        
    branches = []
    for l in sys.stdin:
        oldref, newref, refname = l.split()
        branch = refname.split('/')[-1]
        branches.append(branch)
        # tell trac about the change
        if trac_dir and trac_repo and shutil.which(trac_admin):
            trac_out = subprocess.check_output([trac_admin,
                                                trac_dir,
                                                'changeset',
                                                'added',
                                                trac_repo,
                                                newref])
            trac_out = trac_out.decode('utf-8').strip()
            print('Trac notified of change to',
                  trac_repo,
                  'for',
                  trac_dir,
                  '.\n',
                  trac_out)

    # Notify Jenkins
    jenkins_url = git_config('jenkins.url')
    if not jenkins_url or 'http' not in jenkins_url :
        print( 'Repo not configured for continuous integration.' )
    else:
        print('JURL:',jenkins_url)
        notify_jenkins(jenkins_url,branches)

    # Push changes to mirror
    mirrors = git_config('git.mirror.repo')
    if mirrors:
        for mir in mirrors.split():
            git_out = subprocess.check_output(['git',
                                               'push',
                                               '--mirror',
                                               mir
                                               ]).decode('utf-8').strip()
            print('Pushed to mirror:',mir)
    else:
         print('Not mirrored')
         
if __name__ == '__main__':
    main()
