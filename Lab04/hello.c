// SPDX-License-Identifier: GPL-2.0
#include <linux/errno.h>
#include <linux/init.h>
#include <linux/ktime.h>
#include <linux/list.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/slab.h>

static unsigned int count = 1;
module_param(count, uint, 0444);
MODULE_PARM_DESC(count, "Greeting count: 0..10; 0 and 5..10 emit a warning");

struct greeting_record {
	struct list_head link;
	ktime_t stamp;
};

static LIST_HEAD(journal);

static bool dequeue_stamp(ktime_t *stamp)
{
	struct greeting_record *oldest;

	if (list_empty(&journal))
		return false;
	oldest = list_first_entry(&journal, struct greeting_record, link);
	*stamp = oldest->stamp;
	list_del(&oldest->link);
	kfree(oldest);
	return true;
}

static int __init hello_init(void)
{
	unsigned int index;
	ktime_t discarded;

	if (count > 10) {
		printk(KERN_ERR "hello: count %u exceeds 10\n", count);
		return -EINVAL;
	}
	if (!count || count >= 5)
		printk(KERN_WARNING "hello: unusual count %u\n", count);

	for (index = 0; index < count; ++index) {
		struct greeting_record *record;

		record = kmalloc(sizeof(*record), GFP_KERNEL);
		if (!record)
			goto allocation_failed;
		record->stamp = ktime_get();
		list_add_tail(&record->link, &journal);
		printk(KERN_INFO "Hello, world!\n");
	}
	return 0;

allocation_failed:
	while (dequeue_stamp(&discarded))
		;
	return -ENOMEM;
}

static void __exit hello_exit(void)
{
	ktime_t stamp;
	unsigned int removed = 0;

	while (dequeue_stamp(&stamp))
		printk(KERN_INFO "hello: dequeued %u at %lld ns\n",
		       ++removed, ktime_to_ns(stamp));
}

module_init(hello_init);
module_exit(hello_exit);
MODULE_AUTHOR("Oleksandr Zaviriukha");
MODULE_DESCRIPTION("FIFO journal of kernel greeting timestamps");
MODULE_LICENSE("GPL");
