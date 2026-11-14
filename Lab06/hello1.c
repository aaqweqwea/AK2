// SPDX-License-Identifier: GPL-2.0
#ifdef HELLO_FORCE_DEBUG
#define DEBUG
#endif
#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

#include <linux/errno.h>
#include <linux/init.h>
#include <linux/ktime.h>
#include <linux/list.h>
#include <linux/module.h>
#include <linux/slab.h>

#include "hello1.h"

struct print_record {
	struct list_head link;
	ktime_t begin;
	ktime_t end;
};

static LIST_HEAD(print_journal);

int print_hello(void)
{
	struct print_record *record;

	record = kmalloc(sizeof(*record), GFP_KERNEL);
	if (!record) {
		pr_err("cannot allocate a timing record\n");
		return -ENOMEM;
	}
	record->begin = ktime_get();
	pr_info("Hello, world!\n");
	record->end = ktime_get();
	list_add_tail(&record->link, &print_journal);
	return 0;
}
EXPORT_SYMBOL(print_hello);

static int __init hello1_init(void)
{
	pr_info("timing service ready\n");
	return 0;
}

static void __exit hello1_exit(void)
{
	struct print_record *record, *next;
	unsigned int ordinal = 0;

	pr_debug("journal drain begins\n");
	list_for_each_entry_safe(record, next, &print_journal, link) {
		++ordinal;
		pr_debug("record %u: %lld ns\n", ordinal,
			ktime_to_ns(ktime_sub(record->end, record->begin)));
		list_del(&record->link);
		kfree(record);
	}
	pr_debug("released %u records\n", ordinal);
}

module_init(hello1_init);
module_exit(hello1_exit);
MODULE_AUTHOR("Oleksandr Zaviriukha");
MODULE_DESCRIPTION("Exported greeting service with a print-duration journal");
MODULE_LICENSE("GPL");
