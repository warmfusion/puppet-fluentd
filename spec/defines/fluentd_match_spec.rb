#!/usr/bin/env rspec
require 'spec_helper'

describe 'fluentd::match' do
  let(:title) {'bar'}

  let (:facts) {{
    :osfamily       => 'Debian',
    :lsbdistid      => 'Debian', 
    }}

    context "when creating simple matcher" do
      let(:params) {{
        :pattern    => 'baz',
        :priority   => 20,
        :type       => 'file',
        :type_config     => {
          'time_slice_wait'   => '10m',
          'compress'          => 'gzip',
        }
        }}

        it "should create matcher single segment" do
          should contain_file('/etc/fluent/conf.d/matchers/20-bar.conf')
            .with_content(/<match baz >.*type +file.*time_slice_wait +10m.*compress +gzip.*<\/match>/m)
        end
      end

      context "when multiple patterns" do
        let(:params) {{
          :pattern    => ['baz', 'foo'],
          :type       => 'file',
          :type_config     => { }
          }}

          it "should create matcher for multiple patterns" do
            should contain_file('/etc/fluent/conf.d/matchers/10-bar.conf')
              .with_content(/<match baz foo >/m)
          end
        end


      context "when one pattern and multiple simple options" do
        let(:params) {{
          :pattern    => 'baz',
          :type       => 'file',
          :type_config     => {
            'option1' => 'valueone',
            'option2' => 'value2'
             }
          }}

          it "should create matcher with simple configuration" do
            should contain_file('/etc/fluent/conf.d/matchers/10-bar.conf')
              .with_content(/<match baz >.*option1 +valueone.*option2 +value2.*<\/match>/m)
          end
        end

      context "when one pattern and a nested options configuration" do
        let(:params) {{
          :pattern    => 'baz',
          :type       => 'copy',
          :type_config     => {
            'server' => {
              'option1' => 'valueone',
              'option2' => 'value2'
              }
            }
          }}

          it "should create matcher with a few options" do
            should contain_file('/etc/fluent/conf.d/matchers/10-bar.conf')
              .with_content(/<match baz >.*type +copy.*<server>.*option1 +valueone.*option2 +value2.*<\/server>.*<\/match>/m)
          end
        end

      context "when one pattern and multiple different nested options configuration" do
        let(:params) {{
          :pattern    => 'baz',
          :type       => 'copy',
          :type_config     => {
            'server' => {
              'option1' => 'valueone',
              'option2' => 'value2'
              },
            'secondary' => {
              'type' => 'file',
              'path' => 'someplace'
              }

            }
          }}

          it "should create matcher with both a server and secondary configuration" do
            should contain_file('/etc/fluent/conf.d/matchers/10-bar.conf')
              .with_content(/<match baz >.*type +copy.*<server>.*option1 +valueone.*option2 +value2.*<\/server>.*<secondary>.*type +file.*path +someplace.*<\/secondary>.*<\/match>/m)
          end
        end

      context "when one pattern and multiple similar nested options configuration" do
        let(:params) {{
          :pattern    => 'baz',
          :type       => 'copy',
          :type_config     => {
            'server' => [ 
                {
                'option1' => 'valueone',
                'option2' => 'value2'
                },{
                'type' => 'file',
                'path' => 'someplace'
                }
              ]
            }
          }}

          it "should create matcher with two server sections" do
            should contain_file('/etc/fluent/conf.d/matchers/10-bar.conf')
              .with_content(/<match baz >.*type +copy.*<server>.*option1 +valueone.*option2 +value2.*<\/server>.*<server>.*type +file.*path +someplace.*<\/server>.*<\/match>/m)
          end
        end

      context "when a complex multiple server and secondary configuration is defined" do
        let(:params) {{
          :pattern    => 'baz',
          :type       => 'copy',
          :type_config     => {
            'server' => [ 
                {
                'host' => 'boxone',
                'port' => '1001'
                },{
                'host' => 'boxtwo',
                'port' => '1002'
                }
              ],
            'secondary' => {
              'type' => 'file',
              'path' => 'path'
             },
             'buffer_size' => 100,
            }
          }}

          it "should create matcher accordingly" do
            # This isn't quite as robust as the above regex checks, but its a darn sight easier to read
            should contain_file('/etc/fluent/conf.d/matchers/10-bar.conf')
              .with_content(/<match baz >.*<\/match>/m)
              .with_content(/type +copy/)
              .with_content(/buffer_size +100/)
              .with_content(/<server>.*host +boxone.*port +1001.*<\/server>/m)
              .with_content(/<server>.*host +boxtwo.*port +1002.*<\/server>/m)
              .with_content(/<secondary>.*type +file.*path +path.*<\/secondary>/m)

          end
        end
end

