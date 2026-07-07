#include <linux/delay.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/moduleparam.h>

static int loops = 5;
module_param(loops, int, 0644);
MODULE_PARM_DESC(loops, "Number of calls through the traceable path");

static int delay_ms = 10;
module_param(delay_ms, int, 0644);
MODULE_PARM_DESC(delay_ms, "Delay in the leaf function");

static noinline void ftrace_demo_leaf(int i)
{
	pr_debug("ftrace_target_demo: leaf iteration=%d\n", i);
	if (delay_ms > 0)
		msleep(delay_ms);
}

static noinline void ftrace_demo_middle(int i)
{
	ftrace_demo_leaf(i);
}

static noinline void ftrace_demo_entry(void)
{
	int i;

	for (i = 0; i < loops; i++)
		ftrace_demo_middle(i);
}

static int __init ftrace_target_demo_init(void)
{
	pr_info("ftrace_target_demo: loaded, trace ftrace_demo_entry with function_graph\n");
	ftrace_demo_entry();
	return 0;
}

static void __exit ftrace_target_demo_exit(void)
{
	pr_info("ftrace_target_demo: unloaded\n");
}

module_init(ftrace_target_demo_init);
module_exit(ftrace_target_demo_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("linux-kernel-hacker-roadmap");
MODULE_DESCRIPTION("Day 5 ftrace function graph target module");

