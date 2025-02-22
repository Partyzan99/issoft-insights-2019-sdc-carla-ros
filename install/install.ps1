Function Start-InstallScript {
  [CmdletBinding()]
  param(
    $Activities = $(throw 'The script should consists from the activity objects - { activity: string, operation: string, scriptblock }')
  )
  if (-not ($Activities -is [System.Array])) {
    throw 'The activities should be an array'
  }

  [int]$global = 0
    
  $table = @{ }
  $Activities | % {
    # store current activity
    $activity = $_;

    $id = $table[$activity.activity]
    if ($null -eq $id) {
      # allocate new activity and set initial values
      $id = ++$global;
      $table[$activity.activity] = [PSCustomObject]@{ 'id' = $id; 'iteration' = [double]0.0; 'iterations' = [double]1.0; }
    }
    else {
      # increment iterations count
      ++$table[$activity.activity].iterations
    }
  }

  $Activities | % {
    # store current activity
    $activity = $_;

    # retrieve progress
    $progress = $table[$activity.activity]
        
    # write current activity and progress
    Write-Output '===================='
    Write-Output "$($activity.activity) / $($activity.operation)"
    Write-Output '===================='

    Write-Progress -Id $progress.id `
      -Activity $activity.activity `
      -Status $activity.operation `
      -PercentComplete $([System.Math]::Round(($progress.iteration / $progress.iterations) * 100))

    # execute scriptblock
    if ($null -ne $activity.scriptblock) {
      Invoke-Command -ScriptBlock $activity.scriptblock -ErrorAction Stop | Write-Output
    }

    ++$progress.iteration
    if ($progress.iteration -eq $progress.iterations) {
      Write-Progress -Id $progress.id -Activity $activity.activity -Completed;
    }
  }
}

$WsDir = 'C:\Workshop'
$WsDirUnix = '/mnt/c/Workshop'

$Steps = @(
  @{
    'activity'    = 'Preparing environment'
    'operation'   = 'Install VSCode Python extension'
    'scriptblock' = {
      code --install-extension ms-python.python
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },,
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Refreshing environment'
    'scriptblock' = {
      RefreshEnv
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Installing distro'
    'scriptblock' = {
      & "$WsDir\ubuntu\Ubuntu1804.exe" install --root
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Updating packages tree'
    'scriptblock' = {
      & "$WsDir\ubuntu\Ubuntu1804.exe" run 'apt-get update'
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Upgrading distro'
    'scriptblock' = {
      & "$WsDir\ubuntu\Ubuntu1804.exe" run 'apt-get upgrade -y'
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Updating packages tree'
    'scriptblock' = {
      & "$WsDir\ubuntu\Ubuntu1804.exe" run 'apt-get update'
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Installing python-pip'
    'scriptblock' = {
      & "$WsDir\ubuntu\Ubuntu1804.exe" run 'apt-get install python-pip -y'
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Installing python-protobuf'
    'scriptblock' = {
      & "$WsDir\ubuntu\Ubuntu1804.exe" run 'apt-get install python-protobuf -y'
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Installing python-scipy'
    'scriptblock' = {
      & "$WsDir\ubuntu\Ubuntu1804.exe" run 'apt-get install python-scipy -y'
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Installing pip/simple-pid'
    'scriptblock' = {
      & "$WsDir\ubuntu\Ubuntu1804.exe" run 'pip install simple-pid'
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Installing pip/pygame'
    'scriptblock' = {
      & "$WsDir\ubuntu\Ubuntu1804.exe" run 'pip install pygame'
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },,
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Setting up ROS repositories list'
    'scriptblock' = {
      & "$WsDir\ubuntu\Ubuntu1804.exe" run 'echo "deb http://packages.ros.org/ros/ubuntu bionic main" > /etc/apt/sources.list.d/ros-latest.list'
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Setting up ROS repositories keys'
    'scriptblock' = {
      & "$WsDir\ubuntu\Ubuntu1804.exe" run 'apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116'
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Updating packages tree'
    'scriptblock' = {
      & "$WsDir\ubuntu\Ubuntu1804.exe" run 'apt-get update'
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Installing ROS'
    'scriptblock' = {
      & "$WsDir\ubuntu\Ubuntu1804.exe" run 'apt-get install ros-melodic-desktop-full -y'
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Initializing ROS dependencies'
    'scriptblock' = {
      & "$WsDir\ubuntu\Ubuntu1804.exe" run 'rosdep init'
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Updating ROS dependencies'
    'scriptblock' = {
      & "$WsDir\ubuntu\Ubuntu1804.exe" run 'rosdep update'
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Installing ROS dependencies'
    'scriptblock' = {
      & "$WsDir\ubuntu\Ubuntu1804.exe" run "rosdep install --from-paths $WsDirUnix/carla-ros-bridge/catkin_ws/src --ignore-src -r --rosdistro melodic -y"
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Catkin Make'
    'scriptblock' = {
      & "$WsDir\ubuntu\Ubuntu1804.exe" run "source /opt/ros/melodic/setup.bash && `
        cd $WsDirUnix/carla-ros-bridge/catkin_ws && `
        catkin_make"
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  },
  @{ 
    'activity'    = 'Installing Ubuntu 18.04'
    'operation'   = 'Configuring BASH'
    'scriptblock' = {
      & "$WsDir\ubuntu\Ubuntu1804.exe" run "echo `"source /opt/ros/melodic/setup.bash`" >> ~/.bashrc && `
        echo `"export DISPLAY=:0`" >> ~/.bashrc && `
        echo `"export PYTHONPATH=`$PYTHONPATH:$WsDirUnix/carla/PythonAPI/carla-0.9.3-py2.7-linux-x86_64.egg`" >> ~/.bashrc && `
        echo `"source $WsDirUnix/carla-ros-bridge/catkin_ws/devel/setup.bash`" >> ~/.bashrc"
      if (-not $?) { throw "The process ended with '$($?)' exit code" }
    }
  }
)

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction Stop
Install-Module powershell-yaml -Force -ErrorAction Stop

Start-Transcript -Path "$WsDir\install.transcript"

Start-InstallScript -Activities $Steps -ErrorAction Stop

Stop-Transcript
