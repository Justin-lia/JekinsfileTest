pipeline {
    agent none
    parameters {
        booleanParam(name: 'skip_build', defaultValue: false, description: 'Set to true to skip the build stage')
        booleanParam(name: 'skip_test', defaultValue: true, description: 'Set to true to skip the test stage')
        string(name: 'rpdu_outlet_id', defaultValue: '', description: 'Set the RPDU outlet ID to control the power supply of DUT')
    }

    stages {
        
        stage('check') {
            agent {
                label 'test'
            }
            stages {
                stage('cppcheck') {
                    steps {
			echo "cppcheck teest"
                    }
                }
                stage('luacheck') {
                    steps {
			echo "luacheck teest"
                    }
                }
            }
        }
        stage('cram_test') {
            agent {
                label 'test'
            }
            when { expression { params.skip_test != true } }
            steps {
		echo "luacheck teest"
            }
        }
    }
}

