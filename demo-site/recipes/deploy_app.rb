#Author Nayanajith Chandradasa
#This receipe will do the the code deployment for demo-site

release_dir = node['demo_site']['release_home']
doc_root = node['demo_site']['doc_root']
build_archive = node['demo_site']['build_name']
build_src = node['demo_site']['build_loc']+"/#{build_archive}"

execute 'stop_service' do
    cwd "/tmp"
    user "root"
    command '/etc/init.d/start-demo stop'
    action :run
end

bash 'deploy_code' do
    cwd "/tmp"
    user "root"
    code <<-EOH
    deploymentTime=$(date +"%Y%m%d%H%M%S")
    mkdir -p #{release_dir}/$deploymentTime
    aws s3 cp #{build_src} #{release_dir}/$deploymentTime/
    tar -zxvf #{release_dir}/$deploymentTime/#{build_archive} -C #{release_dir}/$deploymentTime/
    rm -f #{release_dir}/$deploymentTime/#{build_archive}
    unlink #{doc_root}
    ln -sf #{release_dir}/$deploymentTime #{doc_root}
    EOH
    action :run
end

execute 'stop_service' do
    cwd "/tmp"
    user "root"
    command '/etc/init.d/start-demo start'
    action :run
end