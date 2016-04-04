#!/usr/bin/env rspec
require 'spec_helper'

describe 'fluentd::filter' do
  let(:title) {'bar'}

  let (:facts) {{
    :osfamily       => 'Debian',
    :lsbdistid      => 'Debian',
    }}

    context "when creating filter with nested config" do
      let(:params) {{
        :pattern    => 'baz',
        :priority   => 20,
        :config     => {
          'type'    => 'grep',
          'regexp1' => 'message',
          'exclude' => 'string'
        }
        }}

        it "should create filter single segment" do
          should contain_file('/etc/fluent/conf.d/filters/20-bar.conf')
            .with_content(/<filter baz>.*<\/filter>/m)
            .with_content(/.*type.*grep.*/m)
            .with_content(/.*regexp1 message.*/m)
            .with_content(/.*exclude string.*/m)
        end
      end

      context "when multiple patterns" do
        let(:params) {{
          :pattern    => ['baz', 'foo'],
          :config     => {
            'type'              => 'file',
           }
          }}

          it "should create filter for multiple patterns" do
            should contain_file('/etc/fluent/conf.d/filters/10-bar.conf')
              .with_content(/<filter baz foo>/m)
          end
        end


      context "when one pattern and multiple simple options" do
        let(:params) {{
          :pattern    => 'baz',
          :config     => {
            'type'              => 'file',
            'option1' => 'valueone',
            'option2' => 'value2'
             }
          }}

          it "should create filter with simple configuration" do
            should contain_file('/etc/fluent/conf.d/filters/10-bar.conf')
              .with_content(/<filter baz>.*option1 +valueone.*option2 +value2.*<\/filter>/m)
          end
        end

      context "when one pattern and a nested options configuration" do
        let(:params) {{
          :pattern    => 'baz',
          :config     => {
            'type'              => 'record_transformer',
            'record' => {
              'option1' => 'valueone',
              'option2' => 'value2'
              }
            }
          }}

          it "should create filter with a few options" do
            should contain_file('/etc/fluent/conf.d/filters/10-bar.conf')
              .with_content(/<filter baz>.*type +record_transformer.*<record>.*option1 +valueone.*option2 +value2.*<\/record>.*<\/filter>/m)
          end
        end

      context "when one pattern and multiple different nested options configuration" do
        let(:params) {{
          :pattern    => 'baz',
          :config     => {
            'type'              => 'copy',
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

          it "should create filter with both a server and secondary configuration" do
            should contain_file('/etc/fluent/conf.d/filters/10-bar.conf')
              .with_content(/<filter baz>.*type +copy.*<server>.*option1 +valueone.*option2 +value2.*<\/server>.*<secondary>.*type +file.*path +someplace.*<\/secondary>.*<\/filter>/m)
          end
        end

      context "when one pattern and multiple similar nested options configuration" do
        let(:params) {{
          :pattern    => 'baz',
          :config     => {
            'type'              => 'copy',
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

          it "should create filter with two server sections" do
            should contain_file('/etc/fluent/conf.d/filters/10-bar.conf')
              .with_content(/<filter baz>.*type +copy.*<server>.*option1 +valueone.*option2 +value2.*<\/server>.*<server>.*type +file.*path +someplace.*<\/server>.*<\/filter>/m)
          end
        end

      context "when a complex multiple server and secondary configuration is defined" do
        let(:params) {{
          :pattern    => 'baz',
          :config     => {
            'type'              => 'copy',
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

          it "should create filter accordingly" do
            # This isn't quite as robust as the above regex checks, but its a darn sight easier to read
            should contain_file('/etc/fluent/conf.d/filters/10-bar.conf')
              .with_content(/<filter baz>.*<\/filter>/m)
              .with_content(/type +copy/)
              .with_content(/buffer_size +100/)
              .with_content(/<server>.*host +boxone.*port +1001.*<\/server>/m)
              .with_content(/<server>.*host +boxtwo.*port +1002.*<\/server>/m)
              .with_content(/<secondary>.*type +file.*path +path.*<\/secondary>/m)

          end
        end
end
