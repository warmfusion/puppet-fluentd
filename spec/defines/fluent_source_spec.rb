#!/usr/bin/env rspec
require 'spec_helper'

describe 'fluentd::source' do
  let(:title) {'bar'}

  let (:facts) {{
    :osfamily       => 'Debian',
    :lsbdistid      => 'Debian',
    }}


    context "when the type attribute is used" do
      let(:params) {{
          :priority   => 20,
          :type       => 'something',
          :config => {}
        }}

        it "should still contain the type" do
          should contain_file('/etc/fluent/conf.d/sources/20-bar.conf')
            .with_content(/type.*something/m)
        end
    end

        context "when the type_config attribute is used" do
      let(:params) {{
          :priority   => 20,
          :type       => 'something',
          :type_config => {
            'option' => 'value'
          }
        }}


        it "should still contain the configuration" do
          should contain_file('/etc/fluent/conf.d/sources/20-bar.conf')
            .with_content(/option.*value/m)
        end
    end


    context "when creating source with multiple common sections" do
      let(:params) {{
        :priority   => 20,
        :config     => {
          'type'    => 'multiprocess',
          'process' => [
            {
              'cmdline'               => '-c /etc/fluent/fluentd_child1.conf',
              'sleep_before_start'    => '1s',
              'sleep_before_shutdown' => '2s',
            },{
              'cmdline'               => '-c /etc/fluent/fluentd_child2.conf',
              'sleep_before_start'    => '3s',
              'sleep_before_shutdown' => '4s',
            }
          ]
        }
        }}

        it "should create source single segment" do
          should contain_file('/etc/fluent/conf.d/sources/20-bar.conf')
            .with_content(/<source>.*<\/source>/m)
            .with_content(/.*(<process>.*<\/process>[^<]+){2}.*/m)              # Theres should be exactly two <process> sections
            .with_content(/<process>.*child1.*<\/process>/m)                    # and one process section should have child 1 in it
            .with_content(/<process>.*child2.*<\/process>/m)                    # and one should have child 2
            .with_content(/<process>.*sleep_before_shutdown.*4s.*<\/process>/m) # and there should be at least one of these
        end
      end


      context "when multiple simple options" do
        let(:params) {{
          :config     => {
            'type'    => 'file',
            'option1' => 'valueone',
            'option2' => 'value2'
             }
          }}

          it "should create source with simple configuration" do
            should contain_file('/etc/fluent/conf.d/sources/10-bar.conf')
              .with_content(/<source>.*option1 +valueone.*option2 +value2.*<\/source>/m)
          end
        end

      context "when a nested options configuration" do
        let(:params) {{
          :config     => {
            'type'       => 'copy',
            'server' => {
              'option1' => 'valueone',
              'option2' => 'value2'
              }
            }
          }}

          it "should create source with a few options" do
            should contain_file('/etc/fluent/conf.d/sources/10-bar.conf')
              .with_content(/<source>.*type +copy.*<server>.*option1 +valueone.*option2 +value2.*<\/server>.*<\/source>/m)
          end
        end

      context "when multiple different nested options configuration" do
        let(:params) {{
          :config     => {
            'type'   => 'copy',
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

          it "should create source with both a server and secondary configuration" do
            should contain_file('/etc/fluent/conf.d/sources/10-bar.conf')
              .with_content(/<source>.*type +copy.*<server>.*option1 +valueone.*option2 +value2.*<\/server>.*<secondary>.*type +file.*path +someplace.*<\/secondary>.*<\/source>/m)
          end
        end

      context "when multiple similar nested options configuration" do
        let(:params) {{
          :config     => {
            'type'   => 'copy',
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

          it "should create source with two server sections" do
            should contain_file('/etc/fluent/conf.d/sources/10-bar.conf')
              .with_content(/<source>.*type +copy.*<server>.*option1 +valueone.*option2 +value2.*<\/server>.*<server>.*type +file.*path +someplace.*<\/server>.*<\/source>/m)
          end
        end

      context "when a complex multiple server and secondary configuration is defined" do
        let(:params) {{
          :config     => {
            'type'        => 'copy',
            'buffer_size' => 100,
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
            }
          }}

          it "should create source accordingly" do
            # This isn't quite as robust as the above regex checks, but its a darn sight easier to read
            should contain_file('/etc/fluent/conf.d/sources/10-bar.conf')
              .with_content(/<source>.*<\/source>/m)
              .with_content(/type +copy/)
              .with_content(/buffer_size +100/)
              .with_content(/<server>.*host +boxone.*port +1001.*<\/server>/m)
              .with_content(/<server>.*host +boxtwo.*port +1002.*<\/server>/m)
              .with_content(/<secondary>.*type +file.*path +path.*<\/secondary>/m)

          end
        end
end
