/*
 * Copyright (C) 2017 jianhui zhao <jianhuizhao329@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */
 
#ifndef __TMAC_
#define __TMAC_

#include <linux/types.h>
#include <linux/if_ether.h>

struct tmac_entry {
	struct hlist_node	hlist;
	u8 addr[ETH_ALEN];
	unsigned long j;
};

int tmac_init(struct proc_dir_entry *proc);
void tmac_free(struct proc_dir_entry *proc);
int add_tmac(u8 *addr);
int trusted_mac(u8 *addr);

#endif
