# ${license-info}
# ${developer-info}
# ${author-info}

declaration template components/${project.artifactId}/schema;

include 'quattor/schema';

type ${project.artifactId}_skip = {
    "service" : boolean = false
};

# legacy conversion
#   1 -> rescue
#   234 -> multi-user
#   5 -> graphical
# for now limit the targets
type ${project.artifactId}_target = string with match(SELF, "^(default|poweroff|rescue|multi-user|graphical|reboot)$");

type ${project.artifactId}_unit_type = {
    "name" ? string # shortnames are ok; fullnames require matching type
    "targets" : ${project.artifactId}_target[] = list("multi-user") 
    "type" : string = 'service' with match(SELF, '^(service|target|sysv)$')
    "startstop" : boolean = true 
    "state" : string = 'enabled' with match(SELF,"^(enabled|disabled|masked)$")
};

type component_${project.artifactId} = {
    include structure_component
    "skip" : ${project.artifactId}_skip
    # TODO: only ignore implemented so far. To add : disabled and/or masked
    "unconfigured" : string = 'ignore' with match (SELF, '^(ignore)$') # harmless default
    # escaped full unitnames are allowed (or use shortnames and type)
    "unit" ? ${project.artifactId}_unit_type{}
};
