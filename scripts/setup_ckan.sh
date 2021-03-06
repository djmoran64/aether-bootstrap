#!/usr/bin/env bash
#
# Copyright (C) 2018 by eHealth Africa : http://www.eHealthAfrica.org
#
# See the NOTICE file distributed with this work for additional information
# regarding copyright ownership.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
set -Eeuo pipefail

pushd ckan

{
    docker network create aether_internal
} || { # catch
    echo "aether_internal network is ready."
}

{
    docker volume create aether_database_data
} || { # catch
    echo "aether_database_data volume is ready."
}

{ # try
    docker-compose -f docker-compose.yml build
} || { # catch
    echo 'not ready...'
}

docker-compose -f docker-compose.yml up -d
until docker exec -it ckan /usr/local/bin/ckan-paster --plugin=ckan sysadmin -c /etc/ckan/production.ini add admin | tee creds.txt && echo "done"
do
    echo "waiting for ckan container to be ready..."
    sleep 5
done

popd
