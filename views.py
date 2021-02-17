from django.shortcuts import render
from django import http
from django.contrib.auth.decorators import login_required
from os import listdir
from os.path import isdir, isfile, join
import json

reports_path = '/management/desktop-updates/reports'

@login_required
def status_view(request):
    if not request.user.is_superuser:
        return http.HttpResponseForbidden()

    #hosts = [d for d in listdir(reports_path) if isdir(join(reports_path, d))]
    hosts = []
    cpt_total = 0

    try:
        with open(join(reports_path, 'up_hosts')) as up_file:
            up_hosts = up_file.read()
    except:
        up_hosts = ''

    for d in listdir(reports_path):
        if not isdir(join(reports_path, d)):
            continue
        cpt_total += 1

        try:
            with open(join(reports_path, d, 'report.json')) as json_file:
                status = json.load(json_file)
        except:
            status = {}
        try:
            with open(join(reports_path, d, 'updates_list')) as updates_file:
                for last_update in updates_file:
                    pass
        except:
            last_update = '- 0'
        try:
            with open(join(reports_path, 'last_check')) as last_check_file:
                last_check = last_check_file.read()
        except:
            last_check = 'Never'

        try:
            with open(join(reports_path, 'count')) as count_file:
                counters = count_file.read()
        except:
            counters = 'N/A N/A'

        counters = counters.split()
        if len(counters) == 2:
            cpt_connected = counters[0]
            cpt_failed = counters[1]
        else:
            cpt_connected = 0
            cpt_failed = 0            
            
        if isfile(join(reports_path, d, 'connect_failed')):
            status['connect_failed'] = 'Connection failed'

        _last_update = last_update.split()
        if len(_last_update) == 2:
            last_update = _last_update[0]
            last_update_rc = _last_update[1]

        status['ip'] = d
        status['last_update'] = last_update
        status['last_update_rc'] = last_update_rc
        if d in up_hosts:
            status['up'] = 'Up'
        else:
            status['up'] = ''
        hosts.append(status)

    context = {
        'title': 'Hosts',
        'hosts': hosts,
        'last_check': last_check,
        'cpt_total' : cpt_total,
        'cpt_connected' : cpt_connected,
        'cpt_failed' : cpt_failed,
    }
    return render(request, 'host_monitor/list.html', context)

