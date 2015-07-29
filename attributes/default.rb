#
# Cookbook Name:: openresty
# Attribute:: default
#
# Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)
#
# Copyright 2012, Panagiotis Papadomitsos
# Based heavily on Opscode's original nginx cookbook (https://github.com/opscode-cookbooks/nginx)
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Download data
default['openresty']['source']['version']   = '1.7.10.2'
default['openresty']['source']['url']       = "http://agentzh.org/misc/nginx/ngx_openresty-#{node['openresty']['source']['version']}.tar.gz"
default['openresty']['source']['checksum']  = '5e8beafb7b32ba62fd34b323b2e9cf49884b4f0491fccf189f0b88b3e25dd0e4'

# Directories
default['openresty']['dir']                 = '/etc/nginx'
default['openresty']['log_dir']             = '/var/log/nginx'
default['openresty']['cache_dir']           = '/var/cache/nginx'
default['openresty']['run_dir']             = '/var/run'
default['openresty']['binary']              = '/usr/sbin/nginx'
default['openresty']['pid']                 = "#{node['openresty']['run_dir']}/nginx.pid"

# Namespaced attributes in order not to clash with the OHAI plugin
default['openresty']['source']['conf_path'] = "#{node['openresty']['dir']}/nginx.conf"
default['openresty']['source']['prefix']    = '/usr/share'

# Configure flags
default['openresty']['source']['default_configure_flags'] = [
  "--prefix=#{node['openresty']['source']['prefix']}",
  "--conf-path=#{node['openresty']['source']['conf_path']}",
  "--sbin-path=#{node['openresty']['binary']}",
  "--error-log-path=#{node['openresty']['log_dir']}/error.log",
  "--http-log-path=#{node['openresty']['log_dir']}/access.log",
  "--pid-path=#{node['openresty']['pid']}",
  "--lock-path=#{node['openresty']['run_dir']}/nginx.lock",
  "--http-client-body-temp-path=#{node['openresty']['cache_dir']}/client_temp",
  "--http-proxy-temp-path=#{node['openresty']['cache_dir']}/proxy_temp",
  "--http-fastcgi-temp-path=#{node['openresty']['cache_dir']}/fastcgi_temp",
  "--http-uwsgi-temp-path=#{node['openresty']['cache_dir']}/uwsgi_temp",
  "--http-scgi-temp-path=#{node['openresty']['cache_dir']}/scgi_temp",
  '--with-ipv6',
  '--with-md5-asm',
  '--with-sha1-asm',
  '--without-http_ssi_module',
  '--without-mail_smtp_module',
  '--without-mail_imap_module',
  '--without-mail_pop3_module'
]

# Default compile-in modules
default['openresty']['modules']         = [
  'http_ssl_module',
  'http_spdy_module',
  'http_gzip_static_module',
  'http_gunzip_module',
  'http_stub_status_module',
  'http_secure_link_module',
  'http_realip_module',
  'http_flv_module',
  'http_mp4_module',
  'cache_purge_module',
  'fair_module'
]

# If you want to include extra-cookbook modules, just override this array, the will be included in the form
# of include_recipe
default['openresty']['extra_modules']   = []
default['openresty']['configure_flags'] = Array.new

# Configuration options
case node['platform_family']
when 'debian'
  default['openresty']['user']        = 'www-data'
when 'rhel', 'fedora'
  default['openresty']['user']        = 'nginx'
else
  default['openresty']['user']        = 'www-data'
end

default['openresty']['group']         = node['openresty']['user']

if node['os'].eql?('linux') && node['network']['interfaces']['lo']['addresses'].include?('::1')
  default['openresty']['ipv6'] = true
else
  default['openresty']['ipv6'] = false
end

default['openresty']['gzip']              = 'on'
default['openresty']['gzip_http_version'] = '1.0'
default['openresty']['gzip_comp_level']   = '2'
default['openresty']['gzip_proxied']      = 'any'
default['openresty']['gzip_vary']         = 'off'
default['openresty']['gzip_buffers']      = nil
default['openresty']['gzip_types']        = [
  'text/plain',
  'text/css',
  'application/x-javascript',
  'text/xml',
  'application/xml',
  'application/xml+rss',
  'text/javascript',
  'application/javascript',
  'application/json',
  'font/truetype',
  'font/opentype',
  'application/vnd.ms-fontobject',
  'image/svg+xml'
]

default['openresty']['keepalive']                     = 'on'
default['openresty']['keepalive_timeout']             = 5
default['openresty']['worker_processes']              = node['cpu'] && node['cpu']['total'] ? node['cpu']['total'] : 1
default['openresty']['worker_auto_affinity']          = true
default['openresty']['worker_connections']            = 4096
default['openresty']['worker_rlimit_nofile']          = nil
default['openresty']['multi_accept']                  = false

# epoll is available only on Linux kernels >= 2.6
if node['os'].eql?('linux') && node['kernel']['release'].to_f >= 2.6
  default['openresty']['event']                       = 'epoll'
else
  default['openresty']['event']                       = nil
end

# Buffers, size limits etc.
default['openresty']['server_names_hash_bucket_size'] = 64
default['openresty']['client_max_body_size']          = '32M'
default['openresty']['client_body_buffer_size']       = '8K'
default['openresty']['large_client_header_buffers']   = '32 32k'
default['openresty']['types_hash_max_size']           = 2048
default['openresty']['types_hash_bucket_size']        = 64

# Open file cache - for metadata operations only
default['openresty']['open_file_cache'] = {
  'max'       => 1000,
  'inactive'  => '20s',
  'valid'     => '30s',
  'min_uses'  => '8',
  'errors'    => 'on'
}

# Enable default logrotation - disable if you are using something else like AWStats
default['openresty']['logrotate']                     = true
# Disable general access logging - useful for large scale sites
default['openresty']['disable_access_log']            = true
# Enable the default sample vhost config
default['openresty']['default_site_enabled']          = false
# Enable custom PCRE installation - useful for JIT.
default['openresty']['custom_pcre']                   = true
# Enable jemalloc linking
default['openresty']['link_to_jemalloc']              = false
# Modify the maximum number of subrequests
# If you don't modify it from the default 200
# no source patching will occur
default['openresty']['max_subrequests']              = 201
# Generate and include 2048-bit Diffie-Helman parameters by default
default['openresty']['generate_dhparams']            = true
# Enable a custom resolver in the main nginx configuration file
default['openresty']['resolver']                     = nil
default['openresty']['resolver_ttl']                 = '10s'
# LUA package paths
default['openresty']['lua_package_path']             = nil
default['openresty']['lua_package_cpath']            = nil

