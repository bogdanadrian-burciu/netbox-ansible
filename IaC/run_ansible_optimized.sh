#!/bin/bash

# First run specific playbooks and tasks for specific objects, further referenced by many different higher-level objects
# Only then create the objects which are not duplicated in IaC codebase
# Bogdan Adrian Burciu 08/02/2021 vers 1

# -------------------------
# How to run: ./run_ansible_optimized.sh -d ~/parse_excel_servers

# configure script to exit as soon as any line in the bash script fails and show that line
set -e

# using flags for passing input to script
while getopts d: flag
do
    case "${flag}" in
        d) dir_path_iac=${OPTARG};;
    esac
done

# create tags for the unique extra-var values in IaC codebase:
for x in `./get_iac_unique_var.sh -d $dir_path_iac -e tag_name`; do echo ""; echo ""; echo "@@@@@ running Tag creation playbooks for extra-vars in $x @@@@@"; echo ""; echo ""; echo ""; ansible-playbook -i ./hosts -v create_tag.yml -e "external_vars=$x"; done

# create region for the unique extra-var values in IaC codebase:
for x in `./get_iac_unique_var.sh -d $dir_path_iac -e region_name`; do echo ""; echo ""; echo "@@@@@ running Region creation playbooks for extra-vars in $x @@@@@"; echo ""; echo ""; echo ""; ansible-playbook -i ./hosts -v create_region.yml -e "external_vars=$x"; done

# create site for the unique extra-var values in IaC codebase:
for x in `./get_iac_unique_var.sh -d $dir_path_iac -e site_name`; do echo ""; echo ""; echo "@@@@@ running Site creation playbooks for extra-vars in $x @@@@@"; echo ""; echo ""; echo ""; ansible-playbook -i ./hosts -v create_site.yml -e "external_vars=$x"; done

# create tenants for the unique extra-var values in IaC codebase:
#for x in `./get_iac_unique_var.sh -d ~/parse_excel_servers -e tenant_name`; do cat $x | grep tenant_name; done
for x in `./get_iac_unique_var.sh -d $dir_path_iac -e tenant_name`; do echo ""; echo ""; echo "@@@@@ running Tenant creation playbooks for extra-vars in $x @@@@@"; echo ""; echo ""; echo ""; ansible-playbook -i ./hosts -v create_tenant.yml -e "external_vars=$x"; done

# create racks for the unique extra-var values in IaC codebase: 
for x in `./get_iac_unique_var.sh -d $dir_path_iac -e device_rack_name`; do echo ""; echo ""; echo "@@@@@ running Rack creation playbooks for extra-vars in $x @@@@@"; echo ""; echo ""; echo ""; ansible-playbook -i ./hosts -v create_rack.yml -e "external_vars=$x"; done

# create device manufacturers for the unique extra-var values in IaC codebase: 
for x in `./get_iac_unique_var.sh -d $dir_path_iac -e device_manufacturer_name`; do echo ""; echo ""; echo "@@@@@ running Device manufacturer creation playbooks for extra-vars in $x @@@@@"; echo ""; echo ""; echo ""; ansible-playbook -i ./hosts -v create_device_manufacturer_type_role.yml -e "external_vars=$x"; done

# create device type for the unique extra-var values in IaC codebase: 
for x in `./get_iac_unique_var.sh -d $dir_path_iac -e device_part_number`; do echo ""; echo ""; echo "@@@@@ running Device type creation playbooks for extra-vars in $x @@@@@"; echo ""; echo ""; echo ""; ansible-playbook -i ./hosts -v create_device_manufacturer_type_role.yml -e "external_vars=$x"; done

# create device role for the unique extra-var values in IaC codebase: 
for x in `./get_iac_unique_var.sh -d $dir_path_iac -e device_role_name`; do echo ""; echo ""; echo "@@@@@ running Device role creation playbooks for extra-vars in $x @@@@@"; echo ""; echo ""; echo ""; ansible-playbook -i ./hosts -v create_device_manufacturer_type_role.yml -e "external_vars=$x"; done

# create first the Chassis (Blade Switch Enclosure) devices, since those need to referenced by Blade Switches
for x in ` ls -lX $dir_path_iac/external_vars* | grep Chassis | awk '{print $9}' `; do echo ""; echo ""; echo "@@@@@ running Device creation playbooks for extra-vars in $x @@@@@"; echo ""; echo ""; echo ""; ansible-playbook -i ./hosts -v add_device_w_mgmt.yml -e "external_vars=$x"; done

# create the devices and assign them mgmt interfaces with IP addresses:
for x in ` ls -lX $dir_path_iac/external_vars*  | awk '{print $9}' `; do echo ""; echo ""; echo "@@@@@ running Device creation playbooks for extra-vars in $x @@@@@"; echo ""; echo ""; echo ""; ansible-playbook -i ./hosts -v add_device_w_mgmt.yml -e "external_vars=$x"; done
