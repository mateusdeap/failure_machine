# FailureMachine

So you want to know what are your most common failures in RSpec? Pass them trough the Failure Machine.

The idea behind the app is to merely grab json output from RSpec, group together failures with the same root cause
and rank them from most frequent to least frequent.

This is currently in early stages, so the output is pretty limited, it's algorithm for grouping errors together is
the most basic there can be, and it's not thoroughly tested, automatically or otherwise.

In summary, this is a work in progress.

## Installation

For now, the only way to use this is to clone this repo, run `mix install` and then `mix escript.build`
