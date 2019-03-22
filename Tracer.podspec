Pod::Spec.new do |s|
  s.name                  = "Tracer"
  s.version               = "0.1.0"
  s.summary               = "Tracer can track a user's drawing relative to some expected path."

  s.description           = <<-DESC
                            Tracer accepts an expected path that the user
                            attempts to follow. It shows a different color when
                            the user strays too far away from the path.
                            DESC

  s.homepage              = "https://github.com/jamiely/Tracer"

  s.license               = { :type => "MIT", :file => "LICENSE" }

  s.author                = { "Jamie Ly" => "jamie.ly@gmail.com" }
  s.social_media_url      = "http://twitter.com/jamiely"

  s.platform              = :ios
  s.ios.deployment_target = "11.0"

  s.source                = { :git => "https://github.com/jamiely/Tracer.git", :tag => "#{s.version}"}
  s.source_files          = "Sources/**/*.swift"

end
