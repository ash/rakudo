my class IO::Dir does IO {
    has $.abspath;  # assumes we have a trailing slash *ALWAYS*
    has @!parts;

    my %nul = '..' => 1, '.' => 1, '' => 1;

    submethod BUILD(:$!abspath,:$resolve) {
        if $resolve {   # should really be .resolve, but we don't have that yet
            self!parts;

            # front part cleanup
            @!parts.splice(1,1) while %nul.exists_key(@!parts.at_pos(1)); 

            # back part cleanup
            my Int $checks = @!parts.end;
            while $checks > 1 {
                if @!parts.at_pos($checks) -> $part {
                    $part eq '..'
                      ?? @!parts.splice(--$checks, 2)
                      !! $part eq '.'
                        ?? @!parts.splice($checks--, 1)
                        !! $checks--;
                }
                else {
                    @!parts.splice($checks--, 1);
                }
            }
            @!parts.push("");
            $!abspath = @!parts.join('/');
        }
    }

    method !parts() {
        @!parts = $!abspath.split('/') unless @!parts;
    }

    method child($child) {
        $child
          ?? self.new(:abspath($!abspath ~ $child ~ '/'))
          !! self;
    }

    method parent($levels = 1) {
        self!parts;
        @!parts <= $levels + 1
          ?? self.new(:abspath( @!parts[0] ~ '/' ))
          !! self.new(:abspath( @!parts[0 .. *-($levels + 2)].join('/') ~ '/'));
    }

    method Str  { $!abspath }
    method gist { "q|$!abspath|.IO" }
    method perl { "q|$!abspath|.IO" }
    method d { True }
}
