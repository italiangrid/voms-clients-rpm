# RPM packaging for VOMS command-line clients

Spec file and rpmbuild preparation and calls for building rpms out of the VOMS commmand-line clients code.

## Usage

First clone the repo. Then run

```bash
make checkout=master rpm
```

providing checkout point for the repo. This will usually be either a tag for a release or a branch for a snapshot.
